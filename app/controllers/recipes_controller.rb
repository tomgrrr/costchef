# frozen_string_literal: true

class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy duplicate]

  # GET /recipes
  def index
    @recipes = current_user.recipes.includes(:recipe_ingredients, :products).order(:name)
  end

  # GET /recipes/:id
  def show
    @available_products = current_user.products.order(:name)
  end

  # GET /recipes/new
  def new
    @recipe = current_user.recipes.build
    @available_products = current_user.products.order(:name)
  end

  # POST /recipes
  def create
    @recipe = current_user.recipes.build(recipe_params)

    if @recipe.save
      redirect_to recipe_path(@recipe), notice: 'Recette créée avec succès.'
    else
      @available_products = current_user.products.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /recipes/:id/edit
  def edit
    @available_products = current_user.products.order(:name)
  end

  # PATCH/PUT /recipes/:id
  #
  # Cas de recalcul (via Dispatcher.recipe_changed) :
  #   1. Modifier uniquement name/description/sellable_as_component → pas de recalcul
  #   2. Modifier cooking_loss_percentage → recalcul déclenché
  #   3. Modifier has_tray → recalcul déclenché
  #   4. Modifier tray_size_id → recalcul déclenché
  #
  def update
    clear_tray_size_if_no_tray

    if @recipe.update(recipe_params)
      Recalculations::Dispatcher.recipe_changed(@recipe) if calculation_fields_changed?
      redirect_to recipe_path(@recipe), notice: 'Recette mise à jour avec succès.'
    else
      @available_products = current_user.products.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /recipes/:id
  def destroy
    @recipe.destroy!
    redirect_to recipes_path, notice: 'Recette supprimée avec succès.'
  end

  # POST /recipes/:id/duplicate
  def duplicate
    new_recipe = @recipe.dup
    new_recipe.name = generate_unique_copy_name(@recipe.name)
    reset_cached_fields(new_recipe)

    ActiveRecord::Base.transaction do
      new_recipe.save!
      duplicate_components(new_recipe)
      Recalculations::Dispatcher.recipe_component_changed(new_recipe)
    end

    redirect_to recipe_path(new_recipe), notice: 'Recette dupliquée avec succès.'
  rescue ActiveRecord::RecordInvalid
    redirect_to recipe_path(@recipe), alert: 'Erreur lors de la duplication de la recette.'
  end

  private

  def generate_unique_copy_name(original_name)
    name = "#{original_name} (copie)"
    counter = 1
    while current_user.recipes.exists?(name: name)
      counter += 1
      name = "#{original_name} (copie #{counter})"
    end
    name
  end

  def reset_cached_fields(recipe)
    recipe.cached_total_cost = nil
    recipe.cached_total_weight = nil
    recipe.cached_cost_per_kg = nil
    recipe.cached_total_cost_with_loss = nil
  end

  def duplicate_components(new_recipe)
    @recipe.recipe_components.each do |rc|
      new_recipe.recipe_components.create!(
        component: rc.component,
        quantity_kg: rc.quantity_kg
      )
    end
  end

  # Charge la recette uniquement via current_user (isolation multi-tenant)
  def set_recipe
    @recipe = current_user.recipes.find(params[:id])
  end

  # Si has_tray passe à false, forcer tray_size_id à nil pour cohérence
  def clear_tray_size_if_no_tray
    return unless %w[0 false].include?(params.dig(:recipe, :has_tray))

    params[:recipe][:tray_size_id] = nil
  end

  def calculation_fields_changed?
    @recipe.saved_change_to_cooking_loss_percentage? ||
      @recipe.saved_change_to_has_tray? ||
      @recipe.saved_change_to_tray_size_id?
  end

  # Strong parameters - JAMAIS permettre :user_id
  def recipe_params
    params.require(:recipe).permit(
      :name,
      :description,
      :cooking_loss_percentage,
      :sellable_as_component,
      :has_tray,
      :tray_size_id
    )
  end
end
