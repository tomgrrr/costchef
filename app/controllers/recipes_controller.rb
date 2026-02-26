# frozen_string_literal: true

class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy duplicate]

  def index
    @tab = params[:tab] == 'subrecipes' ? 'subrecipes' : 'recipes'
    @recipes = current_user.recipes
                           .includes(:recipe_components, :tray_size)
                           .where(sellable_as_component: @tab == 'subrecipes')
                           .order(:cached_cost_per_kg)
    @recipes = @recipes.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
  end

  def tarifs
    @recipes = current_user.recipes
                           .where(sellable_as_component: false)
                           .includes(:tray_size, :user)
                           .order(:name)
  end

  def show
    @recipe = current_user.recipes
                          .includes(:user, recipe_components: :component)
                          .find(params[:id])
  end

  def new
    @recipe = current_user.recipes.build
    @recipe.sellable_as_component = true if params[:type] == 'subrecipe'
    @tray_sizes = current_user.tray_sizes.order(:name)
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)

    if @recipe.save
      Recalculations::Dispatcher.recipe_changed(@recipe)
      redirect_to @recipe, notice: "Recette créée."
    else
      @tray_sizes = current_user.tray_sizes.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tray_sizes = current_user.tray_sizes.order(:name)
  end

  def update
    was_subrecipe = @recipe.sellable_as_component?
    parent_count = was_subrecipe ? @recipe.parent_recipes_count : 0

    if @recipe.update(recipe_params)
      recalculate_if_needed
      alert_msg = subrecipe_demotion_alert(was_subrecipe, parent_count)
      respond_to do |format|
        format.turbo_stream { @recipe.reload }
        format.html { redirect_to @recipe, notice: "Recette mise à jour.", alert: alert_msg }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("cooking_loss_form_#{@recipe.id}", partial: "recipes/cooking_loss_form", locals: { recipe: @recipe }) }
        format.html do
          @tray_sizes = current_user.tray_sizes.order(:name)
          render :edit, status: :unprocessable_entity
        end
      end
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
    new_recipe = Recipes::Duplicator.call(@recipe)
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

  def subrecipe_demotion_alert(was_subrecipe, parent_count)
    return nil unless was_subrecipe && !@recipe.sellable_as_component? && parent_count.positive?

    "Cette recette était utilisée comme sous-recette dans #{parent_count} recette(s) parente(s). Vérifiez leur cohérence."
  end

end
