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
            inclusion: { in: %w[kg g l cl ml piece] }

  # Champs calculés (remplis par le service PricePerKgCalculator)
  # allow_nil: true car ces champs sont calculés APRÈS la saisie utilisateur
  # Le contrôleur appelle le service qui remplit ces valeurs avant save
  validates :package_quantity_kg,
            numericality: { greater_than: 0 },
            allow_nil: true

  validates :price_per_kg,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # Validation de présence des champs calculés
  validate :calculated_fields_present

  # ============================================
  # Validations personnalisées
  # ============================================
  validate :supplier_belongs_to_same_user

  # ============================================
  # Instance Methods
  # ============================================

  def toggle_active!
    update!(active: !active)
  end

  private

  # Le fournisseur doit appartenir au même utilisateur que le produit
  def supplier_belongs_to_same_user
    return unless product && supplier

    if product.user_id != supplier.user_id
      errors.add(:supplier, "doit appartenir au même utilisateur que le produit")
    end
  end

  # Vérifie que les champs calculés sont présents
  def calculated_fields_present
    if package_quantity_kg.nil? || price_per_kg.nil?
      errors.add(:base, "Les champs calculés doivent être remplis (package_quantity_kg et price_per_kg)")
    end
  end
end
