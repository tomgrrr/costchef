require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Costchef
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks scripts))

    # French app: Rails, Devise and validation messages come from rails-i18n / devise-i18n,
    # app-specific names from config/locales/fr.yml.
    config.i18n.default_locale = :fr
    config.i18n.available_locales = %i[fr en]
    # Lets fr.yml give a full message its own format (messages that already name the field).
    config.active_model.i18n_customize_full_message = true

    # Rack::Attack for brute force protection
    config.middleware.use Rack::Attack

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
