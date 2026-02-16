class TraySize < ApplicationRecord
  belongs_to :user

  # Si on supprime une taille, on met à NULL la référence dans les recettes (Section 6.8)
  has_many :recipes, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
