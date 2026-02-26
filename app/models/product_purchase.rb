# frozen_string_literal: true

class ProductPurchase < ApplicationRecord
  # ============================================
  # PRD Section 6.5 : Table PRODUCT_PURCHASES
  # Conditionnements d'achat avec flag actif
  # ============================================

  # ============================================
  # Associations
  # ============================================
  belongs_to :product
  belongs_to :supplier

  # ============================================
  # Scopes (PRD D13)
  # ============================================
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # ============================================
  # Callbacks
  # ============================================
  before_validation :calculate_derived_fields

  # ============================================
  # Validations (PRD Section 6.5 & 8.3)
  # ============================================

  # Quantité conditionnement > 0
  validates :package_quantity,
            presence: true,
            numericality: { greater_than: 0 }

  # Prix >= 0 (peut être gratuit)
  validates :package_price,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # Unité de saisie : kg, g, l, cl, ml, piece
  validates :package_unit,
            presence: true,
            inclusion: { in: Units::VALID_UNITS }

  # Champs calculés automatiquement par le callback before_validation
  validates :package_quantity_kg,
            numericality: { greater_than: 0 }

  validates :price_per_kg,
            numericality: { greater_than_or_equal_to: 0 }

  # ============================================
  # Validations personnalisées
  # ============================================
  validate :supplier_belongs_to_same_user
  validate :conversion_kg_must_be_positive

  # ============================================
  # Instance Methods
  # ============================================

  def toggle_active!
    update!(active: !active)
  end

  private

  # Calcule les champs dérivés via PricePerKgCalculator avant validation.
  # Ne se déclenche que si les champs de saisie sont présents.
  def calculate_derived_fields
    return unless package_unit.present? && package_quantity.present?

    ProductPurchases::PricePerKgCalculator.call(self)
  end

  # Vérifie que la conversion en kg a produit une valeur exploitable.
  # Cas typique : unité "piece" sans unit_weight_kg sur le produit.
  def conversion_kg_must_be_positive
    return unless package_quantity_kg.present? && package_quantity_kg <= 0

    errors.add(
      :package_quantity_kg,
      "la conversion en kg a échoué (résultat : #{package_quantity_kg}). " \
      "Vérifiez le poids unitaire du produit pour l'unité « #{package_unit} »."
    )
  end

  # Le fournisseur doit appartenir au même utilisateur que le produit
  def supplier_belongs_to_same_user
    return unless product && supplier

    if product.user_id != supplier.user_id
      errors.add(:supplier, "doit appartenir au même utilisateur que le produit")
    end
  end
end
