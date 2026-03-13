# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pre-deployment checklist" do
  let(:root) { Rails.root }

  # ── 1. Secrets & .gitignore ──────────────────────────────────────────

  describe "Secrets & .gitignore" do
    let(:gitignore) { File.read(root.join(".gitignore")) }

    it ".env files are gitignored" do
      expect(gitignore).to include("/.env*")
    end

    it "master.key is gitignored" do
      expect(gitignore).to include("/config/master.key")
    end

    it "no hardcoded secrets in source code" do
      secret_patterns = [
        /password\s*=\s*["'][^"']{8,}["']/i,
        /secret_key_base\s*=\s*["'][0-9a-f]{30,}["']/i,
        /api[_-]?key\s*=\s*["'][^"']{10,}["']/i
      ]

      source_files = Dir.glob(root.join("app/**/*.rb")) +
                     Dir.glob(root.join("config/**/*.rb"))

      # Exclude test/seed/example files
      source_files.reject! { |f| f.include?("spec/") || f.include?("seed") || f.include?("example") }

      violations = []

      source_files.each do |file|
        content = File.read(file)
        secret_patterns.each do |pattern|
          matches = content.scan(pattern)
          matches.each { |m| violations << "#{file}: #{m}" } if matches.any?
        end
      end

      expect(violations).to be_empty, "Hardcoded secrets found:\n#{violations.join("\n")}"
    end
  end

  # ── 2. .env.example completeness ─────────────────────────────────────

  describe ".env.example completeness" do
    it "documents all required ENV vars used in production config" do
      env_example = File.read(root.join(".env.example"))
      production_rb = File.read(root.join("config/environments/production.rb"))
      email_validator = File.read(root.join("config/initializers/email_config_validator.rb"))

      # Extract ENV vars referenced in production config and email validator
      env_refs = (production_rb + email_validator).scan(/ENV\[?\.?fetch?\(?["']([A-Z_]+)["']/).flatten.uniq

      # These have defaults or are optional — exclude from strict check
      optional_vars = %w[RAILS_LOG_LEVEL SECRET_KEY_BASE_DUMMY SKIP_EMAIL_VALIDATION RAILS_MASTER_KEY]
      required_vars = env_refs - optional_vars

      missing = required_vars.reject { |var| env_example.include?(var) }

      expect(missing).to be_empty,
        "ENV vars referenced in production config but missing from .env.example: #{missing.join(', ')}"
    end
  end

  # ── 3. Database ──────────────────────────────────────────────────────

  describe "Database" do
    it "schema.rb is up-to-date with migrations" do
      schema = File.read(root.join("db/schema.rb"))
      schema_version = schema.match(/version:\s*([\d_]+)/)&.captures&.first&.delete("_")

      migration_files = Dir.glob(root.join("db/migrate/*.rb"))
      latest_migration = migration_files.map { |f| File.basename(f).match(/^(\d+)/)[1] }.max

      expect(schema_version).to eq(latest_migration),
        "schema.rb version (#{schema_version}) does not match latest migration (#{latest_migration}). Run `rails db:migrate`."
    end
  end

  # ── 4. Production config ─────────────────────────────────────────────

  describe "Production config" do
    let(:production_rb) { File.read(root.join("config/environments/production.rb")) }

    it "force_ssl is enabled" do
      expect(production_rb).to match(/config\.force_ssl\s*=\s*true/)
    end

    it "active_job queue adapter is configured" do
      expect(production_rb).to match(/config\.active_job\.queue_adapter\s*=/)
    end

    it "no references to uninstalled gems" do
      gemfile = File.read(root.join("Gemfile"))
      gemfile_lock = File.read(root.join("Gemfile.lock"))

      # Detect gem-namespaced config (config.gem_name.something)
      gem_configs = production_rb.scan(/config\.(\w+)\./).flatten.uniq

      # These are built-in Rails config namespaces, not gems
      rails_builtins = %w[
        enable eager action_controller active_storage action_cable
        force assets action_dispatch logger log active_support
        active_record active_job action_mailer i18n cache
        public_file_server content_security_policy host consider
      ]

      external_configs = gem_configs.reject { |g| rails_builtins.include?(g) }

      missing_gems = external_configs.reject do |config_name|
        gem_name = config_name.tr("_", "-")
        underscore_name = config_name
        gemfile.include?(gem_name) || gemfile.include?(underscore_name) ||
          gemfile_lock.include?(gem_name) || gemfile_lock.include?(underscore_name)
      end

      expect(missing_gems).to be_empty,
        "production.rb references config for gems not in Gemfile: #{missing_gems.join(', ')}"
    end
  end

  # ── 5. Security headers ──────────────────────────────────────────────

  describe "Security headers" do
    it "CSP is configured" do
      csp_file = root.join("config/initializers/content_security_policy.rb")
      expect(File.exist?(csp_file)).to be(true), "Content Security Policy initializer missing"

      csp_content = File.read(csp_file)
      expect(csp_content).to include("content_security_policy")
      expect(csp_content).to include("default_src")
    end
  end

  # ── 6. Docker ────────────────────────────────────────────────────────

  describe "Docker" do
    let(:dockerfile) { File.read(root.join("Dockerfile")) }
    let(:entrypoint) { File.read(root.join("bin/docker-entrypoint")) }

    it "runs as non-root user" do
      expect(dockerfile).to match(/^USER\s+\S+/), "Dockerfile should switch to a non-root user"
      # Ensure USER is not root
      user_lines = dockerfile.scan(/^USER\s+(.+)/).flatten
      user_lines.each do |user|
        expect(user.strip).not_to eq("root"), "Dockerfile should not run as root"
      end
    end

    it "entrypoint runs db:prepare" do
      expect(entrypoint).to include("db:prepare"),
        "Docker entrypoint should run db:prepare for automatic migrations"
    end

    it "assets are precompiled during build" do
      expect(dockerfile).to include("assets:precompile"),
        "Dockerfile should precompile assets"
    end
  end
end
