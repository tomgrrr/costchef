# frozen_string_literal: true

class RecipeIngredientsController < ApplicationController
  before_action :set_recipe

  # POST /recipes/:recipe_id/recipe_ingredients
  def create
    # Vérifier que le product appartient aussi à current_user
    product = current_user.products.find(params[:product_id])

    @ingredient = @recipe.recipe_ingredients.build(
      product: product,
      quantity: params[:quantity]
    )

    if @ingredient.save
      redirect_to recipe_path(@recipe), notice: 'Ingrédient ajouté avec succès.'
    else
      redirect_to recipe_path(@recipe), alert: "Erreur lors de l'ajout de l'ingrédient : #{@ingredient.errors.full_messages.join(', ')}"
    end
  end

  # DELETE /recipes/:recipe_id/recipe_ingredients/:id
  def destroy
    @ingredient = @recipe.recipe_ingredients.find(params[:id])
    @ingredient.destroy!
    redirect_to recipe_path(@recipe), notice: 'Ingrédient retiré avec succès.'
  end

  private

  # Isolation stricte : la recette doit appartenir à current_user
  def set_recipe
    @recipe = current_user.recipes.find(params[:recipe_id])
  end
end
