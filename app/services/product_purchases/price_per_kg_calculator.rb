# frozen_string_literal: true

module ProductPurchases
  # PRD Section 7.1 : PricePerKgCalculator
  #
  # Rôle : Normaliser et calculer les champs dérivés d'un achat fournisseur.
  # Entrée : Un ProductPurchase
  # Sorties : package_quantity_kg et price_per_kg
  #
  # Ce service ne déclenche aucun recalcul en cascade.
  # Il est appelé par le Dispatcher avant la sauvegarde d'un achat.
  #
  class PricePerKgCalculator
    # Conversions supportées (PRD Section 7.1 & Module 6)
    UNIT_CONVERSIONS = {
      'kg' => ->(qty, _product) { qty },
      'g' => ->(qty, _product) { qty / 1000.0 },
      'l' => ->(qty, _product) { qty }, # 1L = 1kg (D2)
      'cl' => ->(qty, _product) { qty / 100.0 },
      'ml' => ->(qty, _product) { qty / 1000.0 },
      'piece' => ->(qty, product) { qty * (product&.unit_weight_kg || 0) }
    }.freeze

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

    # Convertit la quantité saisie en kg
    def calculate_quantity_kg
      unit = @purchase.package_unit&.downcase || 'kg'
      quantity = @purchase.package_quantity || 0
      product = @purchase.product

      converter = UNIT_CONVERSIONS[unit]
      @purchase.package_quantity_kg = if converter
                                        converter.call(quantity, product)
                                      else
                                        # Unité inconnue : on assume kg
                                        quantity
                                      end

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
