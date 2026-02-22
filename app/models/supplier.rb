# frozen_string_literal: true

class Supplier < ApplicationRecord
  # ============================================
  # PRD Section 6.4 : Table SUPPLIERS
  # D8: Désactivation (soft delete) ET Suppression (hard delete)
  # ============================================

  # ============================================
  # Associations
  # ============================================
  belongs_to :user

  # PRD: RESTRICT par défaut, CASCADE si "Forcer la suppression"
  # La gestion du force delete se fait dans le controller
  has_many :product_purchases, dependent: :restrict_with_error

  # ============================================
  # Scopes
  # ============================================
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # ============================================
  # Validations (PRD Section 8.3)
  # ============================================
  validates :name, presence: true, uniqueness: { scope: :user_id }

  # ============================================
  # Instance Methods
  # ============================================

  # Désactive le fournisseur (soft delete)
  def deactivate!
    update!(active: false)
  end

  # Réactive le fournisseur
  def activate!
    update!(active: true)
  end

  # Vérifie si le fournisseur a des achats
  def has_purchases?
    product_purchases.exists?
  end

  # Suppression forcée avec cascade (achats + fournisseur) dans une transaction.
  # Retourne les product_ids impactés pour que l'appelant (contrôleur)
  # puisse déclencher les recalculs via le Dispatcher.
  def force_destroy!
    impacted_product_ids = product_purchases.pluck(:product_id).uniq
    transaction do
      ProductPurchase.where(supplier_id: id).delete_all
      destroy!
    end
    impacted_product_ids
  end
end
