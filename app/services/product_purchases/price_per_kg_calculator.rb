# frozen_string_literal: true

module ProductPurchases
  # PRD Section 7.1 : PricePerKgCalculator
  #
  # Rôle : Normaliser et calculer les champs dérivés d'un achat fournisseur.
  # Entrée : Un ProductPurchase
  # Sorties : package_quantity_kg et price_per_kg
  #
  # Ce service ne déclenche aucun recalcul en cascade.
  # Il est appelé automatiquement par le callback before_validation de ProductPurchase.
  #
  class PricePerKgCalculator
    # Conversion d'unités déléguée à Units::Converter (source unique de vérité)

    def self.call(purchase)
      new(purchase).call
    end

    def initialize(purchase)
      @purchase = purchase
    end

    # Calcule et assigne les valeurs sans sauvegarder
    # Retourne le purchase modifié
    def call
      return @purchase unless @purchase

      calculate_quantity_kg
      calculate_price_per_kg

      @purchase
    end

    private

    # Convertit la quantité saisie en kg via Units::Converter
    def calculate_quantity_kg
      unit = @purchase.package_unit || 'kg'
      quantity = @purchase.package_quantity || 0

      @purchase.package_quantity_kg = Units::Converter.to_kg(
        quantity, unit, product: @purchase.product
      )

      # Sécurité : jamais négatif ou zéro pour éviter division par zéro
      @purchase.package_quantity_kg = 0.001 if @purchase.package_quantity_kg <= 0
    end

    # Calcule le prix au kg
    def calculate_price_per_kg
      price = @purchase.package_price || 0
      quantity_kg = @purchase.package_quantity_kg || 0.001

      # PRD Section 7.1 : price_per_kg = package_price / package_quantity_kg
      @purchase.price_per_kg = if quantity_kg > 0
                                 price / quantity_kg
                               else
                                 0
                               end
    end
  end
end
