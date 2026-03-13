class Rack::Attack
  # Throttle login attempts by IP: 5 requests per minute
  throttle("logins/ip", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Throttle login attempts by email: 5 requests per minute
  throttle("logins/email", limit: 5, period: 60.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle signup attempts by IP: 3 requests per minute
  throttle("signups/ip", limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == "/signup" && req.post?
  end

  # Throttle password reset attempts by IP: 5 requests per minute
  throttle("password_resets/ip", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/users/password" && req.post?
  end

  # Throttle admin invitation creation by IP: 5 requests per minute
  throttle("admin_invitations/ip", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/admin/invitations" && req.post?
  end

  # Custom throttle response
  self.throttled_responder = lambda do |_req|
    [
      429,
      { "Content-Type" => "text/plain" },
      ["Trop de tentatives de connexion. Veuillez réessayer dans une minute."]
    ]
  end
end

# Disable Rack::Attack in test by default (enabled explicitly in rack_attack_spec)
Rack::Attack.enabled = false if Rails.env.test?
