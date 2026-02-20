# frozen_string_literal: true

class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy duplicate]

  def index
    @recipes = current_user.recipes
                           .includes(:recipe_components, :tray_size)
                           .order(:cached_cost_per_kg)
    @recipes = @recipes.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
  end

  def show
    @recipe = current_user.recipes
                          .includes(recipe_components: :component)
                          .find(params[:id])
  end

  def new
    @recipe = current_user.recipes.build
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)

    if @recipe.save
      Recalculations::Dispatcher.recipe_changed(@recipe)
      redirect_to @recipe, notice: "Recette créée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @recipe.update(recipe_params)
      recalculate_if_needed
      redirect_to @recipe, notice: "Recette mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @recipe.used_as_subrecipe?
      redirect_to recipes_path,
                  alert: "Cette recette est utilisée comme sous-recette dans #{@recipe.parent_recipes_count} recette(s) et ne peut pas être supprimée."
    else
      @recipe.destroy!
      redirect_to recipes_path, notice: "Recette supprimée."
    end
  end

  def duplicate
    new_recipe = build_duplicate
    if new_recipe.save
      Recalculations::Dispatcher.recipe_changed(new_recipe)
      redirect_to new_recipe, notice: "Recette dupliquée."
    else
      redirect_to @recipe, alert: "Impossible de dupliquer la recette."
    end
  end

  private

  def set_recipe
    @recipe = current_user.recipes.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :name, :description, :cooking_loss_percentage,
      :sellable_as_component, :has_tray, :tray_size_id
    )
  end

  def recalculate_if_needed
    fields = %w[cooking_loss_percentage has_tray tray_size_id]
    return unless (@recipe.previous_changes.keys & fields).any?

    Recalculations::Dispatcher.recipe_changed(@recipe)
  end

  def build_duplicate
    new_recipe = @recipe.dup
    new_recipe.name = "#{@recipe.name} (copie)"
    @recipe.recipe_components.each do |rc|
      new_recipe.recipe_components.build(rc.attributes.except("id", "parent_recipe_id", "created_at", "updated_at"))
    end
    new_recipe
  end
end
