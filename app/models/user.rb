# frozen_string_literal: true

class User < ApplicationRecord
  # PRD Module 1 : Devise sans :registerable
  # L'inscription se fait uniquement via invitation admin
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Relations
  has_many :products, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :created_invitations, class_name: 'Invitation', foreign_key: :created_by_admin_id, dependent: :nullify

  # Validations (email et password gérés par Devise)
  validates :first_name, length: { maximum: 255 }
  validates :last_name, length: { maximum: 255 }
  validates :company_name, length: { maximum: 255 }
end
