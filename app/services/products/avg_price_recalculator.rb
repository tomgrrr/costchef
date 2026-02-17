# frozen_string_literal: true

module Products
  # PRD Section 7.2 : AvgPriceRecalculator
  #
  # Rôle : Calculer le prix moyen pondéré d'un produit.
  # Entrée : Un Product
  # Sortie : product.avg_price_per_kg
  #
  # Règles (PRD D14) :
  # - Moyenne pondérée par kg sur achats actifs uniquement
  # - Si aucun achat actif ou somme kg = 0 : avg_price_per_kg = 0 (jamais nil)
  #
  # Ce service ne recalcule pas directement les recettes.
  # C'est le Dispatcher qui orchestre la propagation.
  #
  class AvgPriceRecalculator
    def self.call(product)
      new(product).call
    end

    def initialize(product)
      @product = product
    end

    # Calcule et persiste le prix moyen pondéré
    # Retourne le produit mis à jour
    def call
      return @product unless @product

      avg_price = calculate_weighted_average

      # PRD D14 : jamais nil, défaut 0
      @product.update_columns(avg_price_per_kg: avg_price)

      @product
    end

    private

    # Calcule la moyenne pondérée : SUM(qty_kg * price_per_kg) / SUM(qty_kg)
    def calculate_weighted_average
      active_purchases = @product.product_purchases.active

      return 0 if active_purchases.empty?

      # Calcul en une seule requête SQL pour la performance
      result = active_purchases.select(
        'SUM(package_quantity_kg * price_per_kg) as weighted_sum',
        'SUM(package_quantity_kg) as total_kg'
      ).take

      total_kg = result.total_kg.to_f
      weighted_sum = result.weighted_sum.to_f

      return 0 if total_kg <= 0

      (weighted_sum / total_kg).round(4)
    end
  end
end
