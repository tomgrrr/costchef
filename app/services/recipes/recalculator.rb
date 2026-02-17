# frozen_string_literal: true

module Recipes
  # PRD Section 7.3 : Recalculator
  #
  # Rôle : Recalculer tous les champs cached_* d'une recette.
  # Entrée : Une Recipe
  # Sorties : cached_total_cost, cached_raw_weight, cached_total_weight, cached_cost_per_kg
  #
  # Règles (PRD Section 7.3 & 8.1) :
  # - Composant Product : line_cost = quantity_kg × product.avg_price_per_kg
  # - Composant Recipe : line_cost = quantity_kg × subrecipe.cached_cost_per_kg
  # - cached_total_cost = SUM(line_cost)
  # - cached_raw_weight = SUM(quantity_kg)
  # - cached_total_weight = cached_raw_weight × (1 - cooking_loss_pct / 100)
  # - cached_cost_per_kg = cached_total_cost / cached_total_weight (si > 0)
  #
  # Persistance via update_columns (pas de callbacks, pas de side effects).
  #
  class Recalculator
    def self.call(recipe)
      new(recipe).call
    end

    def initialize(recipe)
      @recipe = recipe
    end

    # Recalcule et persiste les champs cached_*
    # Retourne la recette mise à jour
    def call
      return @recipe unless @recipe

      total_cost = calculate_total_cost
      raw_weight = calculate_raw_weight
      total_weight = calculate_total_weight(raw_weight)
      cost_per_kg = calculate_cost_per_kg(total_cost, total_weight)

      # Persistance sans callbacks (PRD Section 7.3)
      @recipe.update_columns(
        cached_total_cost: total_cost.round(2),
        cached_raw_weight: raw_weight.round(3),
        cached_total_weight: total_weight.round(3),
        cached_cost_per_kg: cost_per_kg.round(2)
      )

      @recipe
    end

    private

    # Calcule le coût total de tous les composants
    def calculate_total_cost
      @recipe.recipe_components.includes(:component).sum do |component|
        line_cost(component)
      end
    end

    # Calcule le coût d'une ligne (composant)
    def line_cost(component)
      quantity = component.quantity_kg.to_f
      price = unit_price_for(component)
      quantity * price
    end

    # Récupère le prix unitaire selon le type de composant
    def unit_price_for(component)
      linked = component.component
      return 0.0 unless linked

      case component.component_type
      when 'Product' then linked.avg_price_per_kg.to_f
      when 'Recipe'  then linked.cached_cost_per_kg.to_f
      else 0.0
      end
    end

    # Calcule le poids brut total (avant cuisson)
    def calculate_raw_weight
      @recipe.recipe_components.sum(:quantity_kg) || 0
    end

    # Calcule le poids final (après cuisson)
    def calculate_total_weight(raw_weight)
      loss_percentage = @recipe.cooking_loss_percentage || 0

      # PRD : cached_total_weight = cached_raw_weight × (1 - cooking_loss_pct / 100)
      raw_weight * (1 - loss_percentage / 100.0)
    end

    # Calcule le coût au kg final
    def calculate_cost_per_kg(total_cost, total_weight)
      return 0 if total_weight <= 0

      # PRD : cached_cost_per_kg = cached_total_cost / cached_total_weight
      total_cost / total_weight
    end
  end
end
