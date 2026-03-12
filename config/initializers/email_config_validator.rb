# Valide la config email au démarrage en production
Rails.application.config.after_initialize do
  next if Rails.env.test?
  next if ENV['SKIP_EMAIL_VALIDATION'] == 'true'

  if Rails.env.production?
    required = %w[SMTP_ADDRESS SMTP_USERNAME SMTP_PASSWORD MAILER_FROM_ADDRESS APP_HOST]
    missing = required.select { |var| ENV[var].blank? }

    if missing.any?
      raise "Config email incomplète. Variables manquantes: #{missing.join(', ')}"
    end

    Rails.logger.info "[Email] ✓ Config validée (#{ENV['SMTP_ADDRESS']})"
  end
end
