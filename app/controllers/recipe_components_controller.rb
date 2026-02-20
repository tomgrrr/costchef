# frozen_string_literal: true

class RecipeComponentsController < ApplicationController
  before_action :set_recipe
  before_action :set_component, only: %i[update destroy]

  def create
    @component = @recipe.recipe_components.build(component_params)
    assign_quantity_kg

    if @component.save
      Recalculations::Dispatcher.recipe_component_changed(@recipe)
      @recipe.reload
      respond_to do |format|
        format.turbo_stream { render_success_streams }
        format.html { redirect_to @recipe, notice: 'Composant ajouté.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render_form_stream }
        format.html { redirect_to @recipe, alert: "Erreur lors de l'ajout." }
      end
    end
  end

  def update
    @component.assign_attributes(component_params)
    assign_quantity_kg

    if @component.save
      Recalculations::Dispatcher.recipe_component_changed(@recipe)
      @recipe.reload
      respond_to do |format|
        format.turbo_stream { render_success_streams }
        format.html { redirect_to @recipe, notice: 'Composant mis à jour.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render_form_stream }
        format.html { redirect_to @recipe, alert: 'Erreur lors de la mise à jour.' }
      end
    end
  end

  def destroy
    @component.destroy!
    Recalculations::Dispatcher.recipe_component_changed(@recipe)
    @recipe.reload

    respond_to do |format|
      format.turbo_stream { render_success_streams }
      format.html { redirect_to @recipe, notice: 'Composant supprimé.' }
    end
  end

  private

  def set_recipe
    @recipe = current_user.recipes.find(params[:recipe_id])
  end

  def set_component
    @component = @recipe.recipe_components.find(params[:id])
  end

  def component_params
    params.require(:recipe_component)
          .permit(:component_type, :component_id, :quantity_unit)
  end

  def assign_quantity_kg
    raw = params.dig(:recipe_component, :quantity).to_s
    quantity = raw.present? ? BigDecimal(raw) : BigDecimal('0')
    unit = @component.quantity_unit
    product = resolve_product

    @component.quantity_kg = Units::Converter.to_kg(quantity, unit, product: product)
  end

  def resolve_product
    return nil unless @component.component_type == 'Product'

    current_user.products.find(@component.component_id)
  end

  def render_success_streams
    render turbo_stream: [
      turbo_stream.replace(
        "components_#{@recipe.id}",
        partial: 'recipes/components_list',
        locals: { recipe: @recipe }
      ),
      turbo_stream.replace(
        "summary_#{@recipe.id}",
        partial: 'recipes/recipe_summary',
        locals: { recipe: @recipe }
      ),
      turbo_stream.replace(
        "component_form_#{@recipe.id}",
        partial: 'recipe_components/form',
        locals: form_locals(@recipe.recipe_components.build)
      )
    ]
  end

  def render_form_stream
    render turbo_stream: turbo_stream.replace(
      "component_form_#{@recipe.id}",
      partial: 'recipe_components/form',
      locals: form_locals(@component)
    )
  end

  def form_locals(component)
    {
      recipe: @recipe,
      component: component,
      available_products: current_user.products.order(:name),
      available_subrecipes: current_user.recipes
                                        .usable_as_subrecipe
                                        .where.not(id: @recipe.id)
                                        .order(:name)
    }
  end
end
