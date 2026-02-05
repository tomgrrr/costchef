# frozen_string_literal: true

# PRD Module 1 : Inscription via lien sécurisé généré par l'admin
# Table dédiée pour gérer les invitations de manière traçable et sécurisée
class Invitation < ApplicationRecord
  # Relations
  belongs_to :created_by_admin, class_name: 'User'

  # Validations
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Validation : l'email ne doit pas déjà être enregistré comme utilisateur
  validate :email_not_already_registered, on: :create

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  # Scopes
  scope :pending, -> { where(used_at: nil).where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :used, -> { where.not(used_at: nil) }

  # Une invitation est valide si non utilisée et non expirée
  def valid_for_signup?
    used_at.nil? && expires_at > Time.current
  end

  # Marque l'invitation comme utilisée
  def mark_as_used!
    update!(used_at: Time.current)
  end

  # Statut lisible pour l'affichage admin
  def status
    return :used if used_at.present?
    return :expired if expires_at <= Time.current

    :pending
  end

  private

  # Génère un token sécurisé, long et non devinable
  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  # Définit l'expiration à 7 jours par défaut
  def set_expiration
    self.expires_at ||= 7.days.from_now
  end

  # Vérifie que l'email n'est pas déjà utilisé par un utilisateur existant
  def email_not_already_registered
    return if email.blank?

    if User.exists?(email: email.downcase)
      errors.add(:email, 'est déjà utilisé par un compte existant')
    end
  end
end
