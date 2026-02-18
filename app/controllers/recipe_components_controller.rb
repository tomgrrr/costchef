# frozen_string_literal: true

class RecipeComponentsController < ApplicationController
  before_action :set_recipe

  # POST /recipes/:recipe_id/recipe_components
  def create
    @component = @recipe.recipe_components.build(component_params)

    if @component.save
      Recalculations::Dispatcher.recipe_component_changed(@recipe)
      redirect_to recipe_path(@recipe), notice: 'Ingrédient ajouté. Coûts recalculés.'
    else
      redirect_to recipe_path(@recipe), alert: @component.errors.full_messages.join(', ')
    end
  end

  # DELETE /recipes/:recipe_id/recipe_components/:id
  def destroy
    @component = @recipe.recipe_components.find(params[:id])
    @component.destroy!
    Recalculations::Dispatcher.recipe_component_changed(@recipe)
    redirect_to recipe_path(@recipe), notice: 'Ingrédient retiré. Coûts recalculés.'
  end

  private

  def set_recipe
    @recipe = current_user.recipes.find(params[:recipe_id])
  end

  def component_params
    params.require(:recipe_component).permit(:component_id, :component_type, :quantity_kg)
  end
end
