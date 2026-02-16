class Supplier < ApplicationRecord
  belongs_to :user
  has_many :product_purchases
  # Note: dependent: :destroy n'est pas mis ici car la suppression est conditionnelle (voir check_purchases)

  validates :name, presence: true, uniqueness: { scope: :user_id }

  # Section 8.4 & D8 : Suppression bloquée si des lignes d'achat existent
  before_destroy :check_purchases_before_destroy

  private

  def check_purchases_before_destroy
    if product_purchases.exists?
      # Le controller devra gérer le "Forcer la suppression" en supprimant
      # d'abord les product_purchases manuellement avant de rappeler destroy sur le supplier.
      errors.add(:base, "Impossible de supprimer : des lignes d'achat existent.")
      throw(:abort)
    end
  end
end
