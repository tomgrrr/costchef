# frozen_string_literal: true

require 'csv'

class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy duplicate export_excel]

  def index
    @tab = params[:tab] == 'subrecipes' ? 'subrecipes' : 'recipes'
    session[:recipes_back] = { search: params[:search], tab: @tab, per_page: params[:per_page] }.compact
    scope = current_user.recipes
                        .includes(recipe_components: :component)
                        .includes(:tray_size)
                        .where(sellable_as_component: @tab == 'subrecipes')
                        .order(:cached_cost_per_kg)
    scope = scope.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?

    respond_to do |format|
      format.html { @pagy, @recipes = pagy(scope, limit: recipes_per_page) }
      format.csv { send_recipes_csv(scope) }
    end
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

    detailed = params[:detailed] == "1"
    send_data generate_recipe_xlsx(@recipe, detailed: detailed),
              filename: "recette-#{@recipe.name.parameterize}-#{Date.today}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  def export_all_excel
    tab = params[:tab] == 'subrecipes' ? 'subrecipes' : 'recipes'
    recipes = current_user.recipes
                          .includes(recipe_components: :component)
                          .where(sellable_as_component: tab == 'subrecipes')
                          .order(:name)

    detailed = params[:detailed] == "1"
    prefix = tab == 'subrecipes' ? 'sous-recettes' : 'recettes'
    send_data generate_all_recipes_xlsx(recipes, detailed: detailed),
              filename: "#{prefix}-#{Date.today}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  def export_full_excel
    recipes = current_user.recipes
                          .includes(recipe_components: :component)
                          .order(:sellable_as_component, :name)
    send_data generate_full_xlsx(recipes),
              filename: "recettes-complet-#{Date.today}.xlsx",
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

  def recipes_per_page
    per_page = params[:per_page].to_i
    [20, 50, 100].include?(per_page) ? per_page : 20
  end

  def set_recipe
    @recipe = current_user.recipes.find(params[:id])
  end

  def recipe_params
    permitted = params.require(:recipe).permit(
      :name, :description, :cooking_loss_percentage,
      :sellable_as_component, :has_tray, :tray_size_id,
      :sold_by_unit, :unit_reference_weight_kg
    )

    # Convertir grammes → kg (le formulaire envoie des grammes)
    if permitted[:unit_reference_weight_kg].present?
      permitted[:unit_reference_weight_kg] = permitted[:unit_reference_weight_kg].to_f / 1000.0
    end

    # Nettoyer le poids si sold_by_unit est décoché
    if permitted[:sold_by_unit] == '0' || permitted[:sold_by_unit] == false
      permitted[:unit_reference_weight_kg] = nil
    end

    permitted
  end

  def recalculate_if_needed
    fields = %w[cooking_loss_percentage has_tray tray_size_id]
    return unless (@recipe.previous_changes.keys & fields).any?

    Recalculations::Dispatcher.recipe_changed(@recipe)
  end

  def generate_recipe_xlsx(recipe, detailed: false)
    package = ::Axlsx::Package.new
    add_recipe_worksheet(package.workbook, recipe, sheet_name: "Recette", detailed: detailed)
    package.to_stream.string
  end

  def generate_all_recipes_xlsx(recipes, detailed: false)
    package = ::Axlsx::Package.new
    wb = package.workbook

    wb.add_worksheet(name: "Résumé") do |sheet|
      header_style = sheet.styles.add_style(b: true, bg_color: "E2E8F0", border: { style: :thin, color: "94A3B8" })
      decimal2 = sheet.styles.add_style(format_code: "0.00")
      decimal3 = sheet.styles.add_style(format_code: "0.000")

      if detailed
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
      else
        sheet.add_row ["Recette", "Poids final (kg)", "Perte cuisson (%)"],
                      style: Array.new(3, header_style)

        recipes.each do |recipe|
          sheet.add_row [
            recipe.name,
            recipe.cached_total_weight,
            recipe.cooking_loss_percentage
          ], style: [nil, decimal3, nil]
        end

        sheet.column_widths 30, 16, 16
      end
    end

    used_names = Set.new(["Résumé"])
    recipes.each do |recipe|
      sheet_name = unique_sheet_name(recipe.name.truncate(31), used_names)
      used_names.add(sheet_name)
      add_recipe_worksheet(wb, recipe, sheet_name: sheet_name, detailed: detailed)
    end

    package.to_stream.string
  end

  def add_recipe_worksheet(wb, recipe, sheet_name:, detailed: false)
    wb.add_worksheet(name: sheet_name) do |sheet|
      title_style = sheet.styles.add_style(b: true, sz: 16)
      bold_style = sheet.styles.add_style(b: true)
      header_style = sheet.styles.add_style(b: true, bg_color: "E2E8F0", border: { style: :thin, color: "94A3B8" })
      decimal3_style = sheet.styles.add_style(format_code: "0.000")
      total_style = sheet.styles.add_style(b: true, border: { style: :thin, color: "94A3B8", edges: [:top] })
      total_dec3_style = sheet.styles.add_style(b: true, format_code: "0.000", border: { style: :thin, color: "94A3B8", edges: [:top] })

      sheet.add_row ["Recette : #{recipe.name}"], style: [title_style]
      sheet.add_row recipe.description.present? ? [recipe.description] : []
      sheet.add_row ["Perte à la cuisson : #{recipe.cooking_loss_percentage}%"], style: [bold_style]
      sheet.add_row []

      if detailed
        decimal2_style = sheet.styles.add_style(format_code: "0.00")
        total_dec2_style = sheet.styles.add_style(b: true, format_code: "0.00", border: { style: :thin, color: "94A3B8", edges: [:top] })

        sheet.add_row ["Type", "Ingrédient", "Quantité (kg)", "Unité", "Coût ligne (€)"],
                      style: Array.new(5, header_style)

        recipe.recipe_components.each do |rc|
          type_label = rc.recipe_component? ? "Sous-recette" : "Produit"
          sheet.add_row [type_label, rc.component.name, rc.quantity_kg, rc.quantity_unit, rc.line_cost],
                        style: [nil, nil, decimal3_style, nil, decimal2_style]
        end

        sheet.add_row ["", "TOTAL", recipe.cached_raw_weight, "", recipe.cached_total_cost],
                      style: [total_style, total_style, total_dec3_style, total_style, total_dec2_style]

        sheet.column_widths 14, 30, 16, 10, 16
      else
        sheet.add_row ["Type", "Ingrédient", "Quantité (kg)", "Unité"],
                      style: Array.new(4, header_style)

        recipe.recipe_components.each do |rc|
          type_label = rc.recipe_component? ? "Sous-recette" : "Produit"
          sheet.add_row [type_label, rc.component.name, rc.quantity_kg, rc.quantity_unit],
                        style: [nil, nil, decimal3_style, nil]
        end

        sheet.add_row ["", "TOTAL", recipe.cached_raw_weight, ""],
                      style: [total_style, total_style, total_dec3_style, total_style]

        sheet.column_widths 14, 30, 16, 10
      end
    end
  end

  def generate_full_xlsx(recipes)
    package = ::Axlsx::Package.new
    wb = package.workbook

    # Styles
    wb.add_worksheet(name: "Toutes les recettes") do |sheet|
      h  = sheet.styles.add_style(b: true, bg_color: "1E3A5F", fg_color: "FFFFFF",
                                  border: { style: :thin, color: "FFFFFF" }, sz: 11)
      h2 = sheet.styles.add_style(b: true, bg_color: "E2E8F0",
                                  border: { style: :thin, color: "94A3B8" })
      recipe_row_style   = sheet.styles.add_style(bg_color: "F0F4FF", b: true)
      dec2 = sheet.styles.add_style(format_code: "0.00")
      dec3 = sheet.styles.add_style(format_code: "0.000")
      recipe_dec2 = sheet.styles.add_style(bg_color: "F0F4FF", b: true, format_code: "0.00")
      recipe_dec3 = sheet.styles.add_style(bg_color: "F0F4FF", b: true, format_code: "0.000")
      pct  = sheet.styles.add_style(format_code: "0.0\"%\"")

      sheet.add_row [
        "Recette", "Type recette", "Perte cuisson (%)",
        "Coût/kg recette (€)", "Poids total recette (kg)", "Coût total recette (€)",
        "Composant", "Type composant",
        "Quantité (kg)", "Unité",
        "Prix/kg composant (€)", "Coût ligne (€)", "% du coût recette"
      ], style: Array.new(13, h)

      recipes.each do |recipe|
        type_recette = recipe.sellable_as_component? ? "Sous-recette" : "Recette"
        total_cost   = recipe.cached_total_cost.to_f

        if recipe.recipe_components.empty?
          sheet.add_row [
            recipe.name, type_recette, recipe.cooking_loss_percentage,
            recipe.cached_cost_per_kg, recipe.cached_total_weight, total_cost,
            "(aucun ingrédient)", "", "", "", "", "", ""
          ], style: [recipe_row_style, recipe_row_style, pct,
                     recipe_dec2, recipe_dec3, recipe_dec2,
                     recipe_row_style, recipe_row_style,
                     recipe_row_style, recipe_row_style,
                     recipe_row_style, recipe_row_style, recipe_row_style]
        else
          recipe.recipe_components.each do |rc|
            comp = rc.component
            comp_type = rc.recipe_component? ? "Sous-recette" : "Produit"
            price_per_kg = rc.recipe_component? ? comp.cached_cost_per_kg.to_f : comp.avg_price_per_kg.to_f
            line_cost    = rc.line_cost.to_f
            pct_cost     = total_cost > 0 ? (line_cost / total_cost * 100).round(1) : 0

            sheet.add_row [
              recipe.name, type_recette, recipe.cooking_loss_percentage,
              recipe.cached_cost_per_kg, recipe.cached_total_weight, total_cost,
              comp.name, comp_type,
              rc.quantity_kg, rc.quantity_unit,
              price_per_kg, line_cost, pct_cost
            ], style: [nil, nil, pct,
                       dec2, dec3, dec2,
                       nil, nil,
                       dec3, nil,
                       dec2, dec2, nil]
          end
        end
      end

      sheet.column_widths 30, 14, 16, 18, 22, 20, 30, 14, 14, 10, 22, 14, 16
    end

    # Onglet résumé recettes
    wb.add_worksheet(name: "Résumé") do |sheet|
      h   = sheet.styles.add_style(b: true, bg_color: "1E3A5F", fg_color: "FFFFFF", sz: 11)
      dec2 = sheet.styles.add_style(format_code: "0.00")
      dec3 = sheet.styles.add_style(format_code: "0.000")
      sub  = sheet.styles.add_style(bg_color: "F0F4FF")
      sub2 = sheet.styles.add_style(bg_color: "F0F4FF", format_code: "0.00")
      sub3 = sheet.styles.add_style(bg_color: "F0F4FF", format_code: "0.000")

      sheet.add_row ["Recette", "Type", "Coût/kg (€)", "Poids (kg)", "Coût total (€)", "Nb ingrédients"],
                    style: Array.new(6, h)

      recipes.each do |r|
        is_sub = r.sellable_as_component?
        s0, s2, s3 = is_sub ? [sub, sub2, sub3] : [nil, dec2, dec3]
        sheet.add_row [
          r.name,
          is_sub ? "Sous-recette" : "Recette",
          r.cached_cost_per_kg,
          r.cached_total_weight,
          r.cached_total_cost,
          r.recipe_components.size
        ], style: [s0, s0, s2, s3, s2, s0]
      end

      sheet.column_widths 35, 14, 14, 14, 14, 16
    end

    package.to_stream.string
  end

  def send_recipes_csv(recipes)
    prefix = @tab == 'subrecipes' ? 'sous-recettes' : 'recettes'
    send_data generate_recipes_csv(recipes),
              filename: "#{prefix}-#{Date.today}.csv",
              type: 'text/csv; charset=utf-8'
  end

  def generate_recipes_csv(recipes)
    CSV.generate(col_sep: ';') do |csv|
      csv << ['Nom', 'Coût/kg (€)', 'Poids final (kg)', 'Perte cuisson (%)']
      recipes.each do |r|
        csv << [r.name, r.cached_cost_per_kg, r.cached_total_weight, r.cooking_loss_percentage]
      end
    end
  end

  def unique_sheet_name(name, used_names)
    return name unless used_names.include?(name)

    (2..).each do |n|
      suffix = " (#{n})"
      candidate = name.truncate(31 - suffix.length) + suffix
      return candidate unless used_names.include?(candidate)
    end
  end
end
