class DailySpecial < ApplicationRecord
  belongs_to :user

  CATEGORIES = %w[meat fish side].freeze

  validates :item_name, presence: true
  validates :entry_date, presence: true

  # Cout au kilo obligatoire et > 0 (Section 8.3)
  validates :cost_per_kg, presence: true, numericality: { greater_than: 0 }

  validates :category, presence: true, inclusion: { in: CATEGORIES }

  # Scopes utiles pour les calculs de moyennes
  scope :meats, -> { where(category: 'meat') }
  scope :fishes, -> { where(category: 'fish') }
  scope :sides, -> { where(category: 'side') }

  scope :meat_average, -> { meats.average(:cost_per_kg) || 0 }
  scope :fish_average, -> { fishes.average(:cost_per_kg) || 0 }
  scope :side_average, -> { sides.average(:cost_per_kg) || 0 }
end
