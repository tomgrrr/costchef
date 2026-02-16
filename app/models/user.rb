class User < ApplicationRecord
  # Gestion de l'authentification (selon section 6.2)
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  # Associations (Cascade delete pour tout sauf les logs logs optionnels)
  has_many :products, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :suppliers, dependent: :destroy
  has_many :tray_sizes, dependent: :destroy
  has_many :daily_specials, dependent: :destroy

  # Validations
  validates :markup_coefficient, presence: true, numericality: { greater_than_or_equal_to: 0.1 }

  # Valeurs par défaut (si non géré par la DB)
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.markup_coefficient ||= 1.0
    self.subscription_active ||= false
    self.admin ||= false
  end
end
