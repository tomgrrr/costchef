class HealthController < ActionController::Base
  def show
    ActiveRecord::Base.connection.execute("SELECT 1")
    render json: { status: "ok", time: Time.current.iso8601 }
  rescue StandardError => e
    render json: { status: "error", message: e.message }, status: :service_unavailable
  end
end
