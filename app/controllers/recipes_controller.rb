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
  def update
    if @recipe.update(recipe_params)
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
    new_recipe.name = "#{@recipe.name} (copie)"

    # S'assurer que le nom est unique
    counter = 1
    while current_user.recipes.exists?(name: new_recipe.name)
      counter += 1
      new_recipe.name = "#{@recipe.name} (copie #{counter})"
    end

    if new_recipe.save
      # Dupliquer les ingrédients
      @recipe.recipe_ingredients.each do |ri|
        new_recipe.recipe_ingredients.create!(
          product: ri.product,
          quantity: ri.quantity
        )
      end

      redirect_to recipe_path(new_recipe), notice: 'Recette dupliquée avec succès.'
    else
      redirect_to recipe_path(@recipe), alert: 'Erreur lors de la duplication de la recette.'
    end
  end

  private

  # Charge la recette uniquement via current_user (isolation multi-tenant)
  def set_recipe
    @recipe = current_user.recipes.find(params[:id])
  end

  # Strong parameters - JAMAIS permettre :user_id
  def recipe_params
    params.require(:recipe).permit(:name, :description)
  end
end
