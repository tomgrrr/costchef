# frozen_string_literal: true

class User < ApplicationRecord
  # ============================================
  # PRD Section 6.2 : Table USERS
  # ============================================

  # Devise modules
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  # ============================================
  # Associations (PRD Section 6.10)
  # Toutes en CASCADE sur suppression user
  # ============================================
  has_many :products, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :suppliers, dependent: :destroy
  has_many :tray_sizes, dependent: :destroy
  has_many :daily_specials, dependent: :destroy
  has_many :invitations, foreign_key: :created_by_admin_id, dependent: :nullify

  # ============================================
  # Validations (PRD Section 6.2 & 8.3)
  # ============================================

  # D10: Coefficient >= 0.1, obligatoire, défaut 1.0
  validates :markup_coefficient,
            presence: true,
            numericality: { greater_than_or_equal_to: 0.1 }

  # ============================================
  # Callbacks
  # ============================================
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.markup_coefficient ||= 1.0
  end
end
