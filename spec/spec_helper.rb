# frozen_string_literal: true

# Configuration RSpec de base
# Ce fichier est chargé par rails_helper.rb
RSpec.configure do |config|
  # Vérifie que les exemples sont correctement définis
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Permet l'utilisation de doubles stricts
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Active le mode shared_context_metadata_behavior
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Désactive le monkey patching de RSpec sur Object
  config.disable_monkey_patching!

  # Affiche les erreurs avec le nom complet de l'exemple
  config.full_backtrace = false

  # Ordre aléatoire des tests pour détecter les dépendances
  config.order = :random
  Kernel.srand config.seed

  # Permet de filtrer les exemples avec :focus
  config.filter_run_when_matching :focus

  # Active le mode verbose pour les erreurs
  config.warnings = false

  # Si un seul fichier est exécuté, utilise le format documentation
  config.default_formatter = 'doc' if config.files_to_run.one?

  # Profiling des exemples les plus lents
  config.profile_examples = 10
end
