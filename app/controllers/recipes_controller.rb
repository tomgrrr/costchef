# frozen_string_literal: true

class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy duplicate export_excel]

  def index
    @tab = params[:tab] == 'subrecipes' ? 'subrecipes' : 'recipes'
    scope = current_user.recipes
                        .includes(:recipe_components, :tray_size)
                        .where(sellable_as_component: @tab == 'subrecipes')
                        .order(:cached_cost_per_kg)
    scope = scope.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?

    @pagy, @recipes = pagy(scope)
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
    if @recipe.update(recipe_params)
      recalculate_if_needed
      alert_msg = @recipe.demotion_alert_message
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

  def export_excel
    @recipe = current_user.recipes
                          .includes(recipe_components: :component)
                          .find(params[:id])

    send_data generate_recipe_xlsx(@recipe),
              filename: "recette-#{@recipe.name.parameterize}-#{Date.today}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  def export_all_excel
    tab = params[:tab] == 'subrecipes' ? 'subrecipes' : 'recipes'
    recipes = current_user.recipes
                          .includes(recipe_components: :component)
                          .where(sellable_as_component: tab == 'subrecipes')
                          .order(:name)

    prefix = tab == 'subrecipes' ? 'sous-recettes' : 'recettes'
    send_data generate_all_recipes_xlsx(recipes),
              filename: "#{prefix}-#{Date.today}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
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

  def generate_recipe_xlsx(recipe)
    package = ::Axlsx::Package.new
    wb = package.workbook

    wb.add_worksheet(name: "Recette") do |sheet|
      title_style = sheet.styles.add_style(b: true, sz: 16)
      bold_style = sheet.styles.add_style(b: true)
      header_style = sheet.styles.add_style(b: true, bg_color: "E2E8F0", border: { style: :thin, color: "94A3B8" })
      decimal3_style = sheet.styles.add_style(format_code: "0.000")
      decimal2_style = sheet.styles.add_style(format_code: "0.00")
      total_style = sheet.styles.add_style(b: true, border: { style: :thin, color: "94A3B8", edges: [:top] })
      total_dec3_style = sheet.styles.add_style(b: true, format_code: "0.000", border: { style: :thin, color: "94A3B8", edges: [:top] })
      total_dec2_style = sheet.styles.add_style(b: true, format_code: "0.00", border: { style: :thin, color: "94A3B8", edges: [:top] })

      sheet.add_row ["Recette : #{recipe.name}"], style: [title_style]
      sheet.add_row recipe.description.present? ? [recipe.description] : []
      sheet.add_row ["Perte à la cuisson : #{recipe.cooking_loss_percentage}%"], style: [bold_style]
      sheet.add_row []
      sheet.add_row ["Type", "Ingrédient", "Quantité (kg)", "Unité", "Coût ligne (€)"],
                    style: [header_style, header_style, header_style, header_style, header_style]

      recipe.recipe_components.each do |rc|
        type_label = rc.recipe_component? ? "Sous-recette" : "Produit"
        sheet.add_row [type_label, rc.component.name, rc.quantity_kg, rc.quantity_unit, rc.line_cost],
                      style: [nil, nil, decimal3_style, nil, decimal2_style]
      end

      sheet.add_row ["", "TOTAL", recipe.cached_raw_weight, "", recipe.cached_total_cost],
                    style: [total_style, total_style, total_dec3_style, total_style, total_dec2_style]

      sheet.column_widths 14, 30, 16, 10, 16
    end

    package.to_stream.string
  end

  def generate_all_recipes_xlsx(recipes)
    package = ::Axlsx::Package.new
    wb = package.workbook

    header_style = nil
    decimal2 = nil
    decimal3 = nil

    wb.add_worksheet(name: "Résumé") do |sheet|
      header_style = sheet.styles.add_style(b: true, bg_color: "E2E8F0", border: { style: :thin, color: "94A3B8" })
      decimal2 = sheet.styles.add_style(format_code: "0.00")
      decimal3 = sheet.styles.add_style(format_code: "0.000")

      sheet.add_row ["Recette", "Coût total (€)", "Poids final (kg)", "Coût/kg (€)", "Perte cuisson (%)"],
                    style: Array.new(5, header_style)

      recipes.each do |recipe|
        sheet.add_row [
          recipe.name,
          recipe.cached_total_cost,
          recipe.cached_total_weight,
          recipe.cached_cost_per_kg,
          recipe.cooking_loss_percentage
        ], style: [nil, decimal2, decimal3, decimal2, nil]
      end

      sheet.column_widths 30, 16, 16, 14, 16
    end

    wb.add_worksheet(name: "Détail ingrédients") do |sheet|
      header_style2 = sheet.styles.add_style(b: true, bg_color: "E2E8F0", border: { style: :thin, color: "94A3B8" })
      dec3 = sheet.styles.add_style(format_code: "0.000")
      dec2 = sheet.styles.add_style(format_code: "0.00")

      sheet.add_row ["Recette", "Type", "Ingrédient", "Quantité (kg)", "Unité", "Coût ligne (€)"],
                    style: Array.new(6, header_style2)

      recipes.each do |recipe|
        recipe.recipe_components.each do |rc|
          type_label = rc.recipe_component? ? "Sous-recette" : "Produit"
          sheet.add_row [
            recipe.name,
            type_label,
            rc.component.name,
            rc.quantity_kg,
            rc.quantity_unit,
            rc.line_cost
          ], style: [nil, nil, nil, dec3, nil, dec2]
        end
      end

      sheet.column_widths 30, 14, 30, 16, 10, 16
    end

    package.to_stream.string
  end
end
