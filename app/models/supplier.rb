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

  # Suppression forcée avec cascade + recalcul
  # Supprime les achats et le fournisseur, puis déclenche le Dispatcher
  def force_destroy!
    impacted_product_ids = collect_impacted_product_ids
    delete_purchases_and_self
    Recalculations::Dispatcher.supplier_force_destroyed(impacted_product_ids)
  end

  private

  def collect_impacted_product_ids
    product_purchases.pluck(:product_id).uniq
  end

  def delete_purchases_and_self
    transaction do
      ProductPurchase.where(supplier_id: id).delete_all
      destroy!
    end
  end
end
