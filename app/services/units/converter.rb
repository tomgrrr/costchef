module Units
  VALID_UNITS = %w[kg g l cl ml piece].freeze

  class Converter
    def self.to_kg(quantity, unit, product: nil)
      new(quantity, unit, product).to_kg
    end

    def self.to_display_unit(quantity_kg, unit, product: nil)
      case unit.to_s.downcase
      when "kg"    then quantity_kg
      when "g"     then quantity_kg * 1000.0
      when "l"     then quantity_kg
      when "cl"    then quantity_kg * 100.0
      when "ml"    then quantity_kg * 1000.0
      when "piece" then self.convert_piece_display(quantity_kg, product)
      else              quantity_kg
      end
    end

    def to_kg
      case @unit
      when "kg"    then @quantity
      when "g"     then @quantity / 1000.0
      when "l"     then @quantity
      when "cl"    then @quantity / 100.0
      when "ml"    then @quantity / 1000.0
      when "piece" then convert_piece
      else              @quantity
      end
    end

    private

    def initialize(quantity, unit, product)
      @quantity = quantity.to_f
      @unit = unit.to_s.downcase
      @product = product
    end

    def convert_piece
      weight = @product&.unit_weight_kg
      return 0.0 if weight.nil? || weight.zero?

      @quantity * weight
    end

    def self.convert_piece_display(quantity_kg, product)
      weight = product&.unit_weight_kg
      return quantity_kg if weight.nil? || weight <= 0

      quantity_kg / weight
    end

    private_class_method :convert_piece_display
  end
end
