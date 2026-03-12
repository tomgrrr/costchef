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

  # Custom throttle response
  self.throttled_responder = lambda do |_req|
    [
      429,
      { "Content-Type" => "text/plain" },
      ["Trop de tentatives de connexion. Veuillez réessayer dans une minute."]
    ]
  end
end
