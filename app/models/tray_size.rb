# frozen_string_literal: true

class TraySize < ApplicationRecord
  # ============================================
  # PRD Section 6.8 : Table TRAY_SIZES
  # Référentiel des tailles de barquettes plastique
  # ============================================

  # ============================================
  # Associations
  # ============================================
  belongs_to :user

  # PRD: SET NULL sur recipes.tray_size_id + has_tray passe à false
  # Géré par le callback before_destroy
  has_many :recipes

  # ============================================
  # Validations (PRD Section 8.3)
  # ============================================

  # Nom unique par utilisateur
  validates :name, presence: true, uniqueness: { scope: :user_id }

  # Prix >= 0
  validates :price,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # ============================================
  # Callbacks
  # ============================================
  before_destroy :nullify_recipes_tray_reference

  # ============================================
  # Instance Methods
  # ============================================

  def recipes_count
    recipes.count
  end

  private

  # PRD Section 6.8: SET NULL + has_tray passe à false
  def nullify_recipes_tray_reference
    recipes.update_all(tray_size_id: nil, has_tray: false)
  end
end
