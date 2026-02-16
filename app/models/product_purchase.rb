class ProductPurchase < ApplicationRecord
  belongs_to :product
  belongs_to :supplier

  # Validations
  validates :package_quantity, presence: true, numericality: { greater_than: 0 }
  validates :package_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :package_unit, presence: true, inclusion: { in: %w[kg g l cl ml piece] }

  # Champs calculés stockés
  validates :package_quantity_kg, presence: true, numericality: { greater_than: 0 }
  validates :price_per_kg, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scope pour le calcul de moyenne (D13)
  scope :active, -> { where(active: true) }
end
