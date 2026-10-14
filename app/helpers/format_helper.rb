# frozen_string_literal: true

# French number formatting for the UI (comma decimals, space thousands).
# Exports (CSV, Excel) keep their own machine-readable formatting.
module FormatHelper
  NBSP = "\u00A0"       # before units: "6,92 €", "8 %"
  THIN_NBSP = "\u202F"  # thousands: "1 024"

  # "6,92 €" — with a unit: "6,92 € / kg". nil renders an em dash.
  def eur(value, unit: nil, precision: 2)
    return '—' if value.nil?

    text = "#{fr_number(value, precision: precision)}#{NBSP}€"
    unit ? "#{text}#{NBSP}/#{NBSP}#{unit}" : text
  end

  def fr_number(value, precision: 2, strip: false)
    number_with_precision(value, precision: precision, separator: ',',
                                 delimiter: THIN_NBSP, strip_insignificant_zeros: strip)
  end

  # Weight stored in kg: "250 g" under 1 kg, "4,215 kg" from 1 kg.
  def weight_label(weight_kg)
    return '—' if weight_kg.nil?

    grams = (weight_kg.to_d * 1000).round
    return "#{grams}#{NBSP}g" if grams < 1000

    "#{fr_number(weight_kg, precision: 3, strip: true)}#{NBSP}kg"
  end

  UNIT_LABELS = { 'kg' => 'kg', 'g' => 'g', 'l' => 'l', 'cl' => 'cl', 'ml' => 'ml', 'piece' => 'pièce(s)' }.freeze

  # Human label for a stored unit code ("piece" -> "pièce(s)").
  def unit_label(unit)
    UNIT_LABELS.fetch(unit.to_s, unit.to_s)
  end

  # Options for a unit <select>: [["pièce(s)", "piece"], ...].
  def unit_options(units)
    units.map { |unit| [unit_label(unit), unit] }
  end

  # "8 %" (French typography: space before the sign).
  def percent(value, precision: 0)
    return '—' if value.nil?

    "#{fr_number(value, precision: precision, strip: precision.positive?)}#{NBSP}%"
  end

  # Short French date: "2 oct.", with the year only when it isn't this year.
  def short_date(date)
    return '—' if date.nil?

    month = %w[janv. févr. mars avr. mai juin juil. août sept. oct. nov. déc.][date.month - 1]
    label = "#{date.day}#{NBSP}#{month}"
    date.year == Date.current.year ? label : "#{label} #{date.year}"
  end
end
