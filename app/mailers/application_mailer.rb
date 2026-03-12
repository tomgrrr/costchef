class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch('MAILER_FROM_ADDRESS', 'CostChef <tom.grenie@gmail.com>') }
  default reply_to: -> { ENV.fetch('MAILER_REPLY_TO', 'tom.grenie@gmail.com') }
  layout "mailer"
end
