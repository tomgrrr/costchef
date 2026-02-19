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

  def self.average_cost_per_kg_for(category)
    where(category: category).average(:cost_per_kg)&.round(2) || 0
  end

  def self.meat_average
    average_cost_per_kg_for('meat')
  end

  def self.fish_average
    average_cost_per_kg_for('fish')
  end

  def self.side_average
    average_cost_per_kg_for('side')
  end
end
