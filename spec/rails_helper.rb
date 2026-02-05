# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

# Chargement automatique des fichiers support
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Fixtures path
  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  # Utilise les transactions pour nettoyer la DB entre chaque test
  config.use_transactional_fixtures = true

  # Infère automatiquement le type de spec basé sur le chemin
  config.infer_spec_type_from_file_location!

  # Filtre les backtrace Rails
  config.filter_rails_from_backtrace!

  # Include ActiveSupport::Testing::TimeHelpers for freeze_time
  config.include ActiveSupport::Testing::TimeHelpers
end
