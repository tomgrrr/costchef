# frozen_string_literal: true

# =============================================================================
# Seeds pour CostChef - Module 1 : Authentification
# =============================================================================
# Exécution : bin/rails db:seed
# =============================================================================

puts "Création des utilisateurs de test..."

# Utilisateur Admin avec abonnement actif
admin = User.find_or_initialize_by(email: "admin@costchef.fr")
admin.assign_attributes(
  password: "password123",
  password_confirmation: "password123",
  first_name: "Admin",
  last_name: "CostChef",
  company_name: "CostChef SAS",
  subscription_active: true,
  subscription_started_at: Date.today,
  subscription_expires_at: 1.year.from_now,
  admin: true
)
admin.save!
puts "  - Admin: admin@costchef.fr (mot de passe: password123)"

# Utilisateur avec abonnement actif
user_active = User.find_or_initialize_by(email: "christophe@traiteur.fr")
user_active.assign_attributes(
  password: "password123",
  password_confirmation: "password123",
  first_name: "Christophe",
  last_name: "Dupont",
  company_name: "Traiteur Dupont",
  subscription_active: true,
  subscription_started_at: Date.today,
  subscription_expires_at: 1.year.from_now,
  admin: false
)
user_active.save!
puts "  - Utilisateur actif: christophe@traiteur.fr (mot de passe: password123)"

# Utilisateur sans abonnement actif (pour tester le gating)
user_inactive = User.find_or_initialize_by(email: "laurent@nouveau.fr")
user_inactive.assign_attributes(
  password: "password123",
  password_confirmation: "password123",
  first_name: "Laurent",
  last_name: "Martin",
  company_name: "Nouveau Traiteur",
  subscription_active: false,
  subscription_started_at: nil,
  subscription_expires_at: nil,
  admin: false
)
user_inactive.save!
puts "  - Utilisateur inactif: laurent@nouveau.fr (mot de passe: password123)"

# Utilisateur Lassalas avec abonnement actif
user_lassalas = User.find_or_initialize_by(email: "lassalas@traiteur.fr")
user_lassalas.assign_attributes(
  password: "password123",
  password_confirmation: "password123",
  first_name: "Dimitri",
  last_name: "Lassalas",
  company_name: "Lassalas Traiteur",
  subscription_active: true,
  subscription_started_at: Date.today,
  subscription_expires_at: 1.year.from_now,
  admin: false
)
user_lassalas.save!
puts "  - Utilisateur actif: lassalas@traiteur.fr (mot de passe: password123)"

# Invitation de démonstration (pour tester le workflow)
puts ''
puts 'Création d\'une invitation de démonstration...'
demo_invitation = Invitation.find_or_initialize_by(email: 'demo@example.com')
if demo_invitation.new_record?
  demo_invitation.created_by_admin = admin
  demo_invitation.save!
  puts "  - Invitation créée pour: demo@example.com"
  puts "  - Token: #{demo_invitation.token}"
  puts "  - URL: http://localhost:3000/signup?token=#{demo_invitation.token}"
else
  puts "  - Invitation existante pour: demo@example.com"
end

puts ''
puts 'Seeds terminés !'
puts ''
puts 'Pour tester l\'authentification :'
puts '  1. bin/dev'
puts '  2. Connectez-vous avec admin@costchef.fr → accès complet + admin'
puts '  3. Connectez-vous avec christophe@traiteur.fr → accès complet'
puts '  4. Connectez-vous avec laurent@nouveau.fr → bloqué (page abonnement requis)'
puts ''
puts 'Pour tester le workflow d\'invitation :'
puts '  1. Connectez-vous en tant qu\'admin (admin@costchef.fr)'
puts '  2. Allez sur /admin/invitations'
puts '  3. Créez une nouvelle invitation'
puts '  4. L\'email est envoyé (visible dans les logs en dev)'
puts '  5. Utilisez le lien /signup?token=xxx pour créer le compte'
