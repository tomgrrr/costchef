module Units
  VALID_UNITS = %w[kg g l cl ml piece].freeze

  ALLOWED_PURCHASE_UNITS = {
    "kg" => %w[kg g].freeze,
    "l" => %w[l cl ml].freeze,
    "piece" => %w[piece].freeze
  }.freeze

  def self.allowed_for(base_unit)
    ALLOWED_PURCHASE_UNITS.fetch(base_unit.to_s, [])
  end
end
