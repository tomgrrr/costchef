# frozen_string_literal: true

module Import
  class TabParser
    SUMMARY_PATTERNS = /\A(Moy|Ecart|CV|Moyenne|Ecart type|Ecartype)\b/i.freeze
    HEADER_PATTERNS = /\A(Date|Quantité|Prix|Fournisseur)\b/i.freeze

    def self.call(spreadsheet, sheet_name, section)
      new(spreadsheet, sheet_name, section).call
    end

    def initialize(spreadsheet, sheet_name, section)
      @sheet = spreadsheet.sheet(sheet_name)
      @sheet_name = sheet_name
      @section = section
      @cols = TabConfig.cols_for(section)
      @no_product_col = section[:no_product_col]
    end

    def call
      return [] unless @sheet.last_row

      @no_product_col ? parse_no_product_rows : parse_standard_rows
    end

    private

    # === Standard parsing (sheets with product name in col 1) ===

    def parse_standard_rows
      results = []
      current_product = @section[:default_product]

      (2..@sheet.last_row).each do |row_num|
        product_cell = cell(row_num, @cols[:product])

        if product_cell.present?
          name = normalize_name(product_cell)
          next if header_row?(name)

          current_product = name unless summary_line?(name)
        end

        next unless current_product
        next if skip_row?(row_num)

        line = build_line(row_num, current_product)
        results << line if line
      end

      results
    end

    # === No-product-col parsing (sheets without product name column) ===

    def parse_no_product_rows
      groups = group_by_blank_lines
      results = []

      groups.each do |group|
        product_name = derive_product_name(group)
        next unless product_name

        group[:rows].each do |row_num|
          line = build_line(row_num, product_name)
          results << line if line
        end
      end

      results
    end

    def group_by_blank_lines
      groups = []
      current_group = nil

      (2..@sheet.last_row).each do |row_num|
        if blank_data_row?(row_num)
          current_group = nil
          next
        end

        unless current_group
          current_group = { rows: [], designations: [], moy_name: nil }
          groups << current_group
        end

        current_group[:rows] << row_num
        collect_group_metadata(current_group, row_num)
      end

      groups
    end

    def collect_group_metadata(group, row_num)
      des = cell(row_num, @cols[:designation])
      group[:designations] << des.to_s if des.present?

      scan_moy_marker(group, row_num)
    end

    def scan_moy_marker(group, row_num)
      return if group[:moy_name]

      max_col = @sheet.last_column || 10
      start_col = (@cols[:designation] || 6) + 1

      (start_col..[max_col, start_col + 4].min).each do |col|
        val = cell(row_num, col)
        next unless val.is_a?(String)

        match = val.match(/\AMoy\s+(.+)/i)
        if match
          group[:moy_name] = match[1].strip
          return
        end
      end
    end

    def derive_product_name(group)
      return nil if group[:rows].empty?

      # Priority 1: Moy marker in summary columns
      return group[:moy_name].capitalize_first_letter if group[:moy_name]

      # Priority 2: Clean up first designation
      first_des = group[:designations].first
      return nil if first_des.blank?

      clean_designation(first_des)
    end

    def clean_designation(text)
      cleaned = text.dup
      cleaned.gsub!(/\b\d+[,.]?\d*\s*(kgs?|g|gr|l|cl|ml|pc|pce|units?)\b/i, "")
      cleaned.gsub!(/\b(sac|boite|bte|bidon|bouteille|bout|carton|ct|pot|sachet|bac|poche)\s*(de\s*)?\b/i, "")
      cleaned.gsub!(/\b\d+\/\d+\b/, "")
      cleaned.gsub!(/\b\d+[%°x*#]\b/i, "")
      cleaned.gsub!(/[*"()]+/, "")
      cleaned.strip!
      cleaned.squish!

      # Take first 4 meaningful words
      words = cleaned.split.first(4).join(" ")
      words.present? ? words : text.strip.squish.split.first(4).join(" ")
    end

    # === Shared methods ===

    def skip_row?(row_num)
      qty = cell(row_num, @cols[:quantity])
      price = cell(row_num, @cols[:price])

      qty.blank? && price.blank?
    end

    def blank_data_row?(row_num)
      qty = cell(row_num, @cols[:quantity])
      price = cell(row_num, @cols[:price])
      supplier = cell(row_num, @cols[:supplier])

      qty.blank? && price.blank? && supplier.blank?
    end

    def summary_line?(name)
      name.match?(SUMMARY_PATTERNS)
    end

    def header_row?(name)
      name.match?(HEADER_PATTERNS)
    end

    def build_line(row_num, product_name)
      raw_qty = cell(row_num, @cols[:quantity])
      raw_price = cell(row_num, @cols[:price])
      supplier = cell(row_num, @cols[:supplier])
      designation = cell(row_num, @cols[:designation])

      qty = parse_quantity(raw_qty)
      price = parse_quantity(raw_price)

      return nil if qty <= 0 || price < 0

      {
        product_name: product_name,
        quantity: qty,
        price: price,
        supplier_name: TabConfig.normalize_supplier(supplier),
        base_unit: @section[:base_unit],
        package_unit: @section[:base_unit],
        designation: designation.to_s.strip,
        date: parse_date(cell(row_num, @cols[:date]))
      }
    end

    def parse_quantity(val)
      return val.to_f if val.is_a?(Numeric)
      return 0.0 if val.blank?

      text = val.to_s.strip.gsub(",", ".")
      match = text.match(/(\d+\.?\d*)/)
      match ? match[1].to_f : 0.0
    end

    def cell(row, col)
      val = @sheet.cell(row, col)
      return nil if val.nil?
      return nil if val.is_a?(String) && val.strip.empty?

      val
    end

    def normalize_name(val)
      val.to_s.strip.squish
    end

    def parse_date(val)
      return nil if val.blank?
      return val if val.is_a?(Date) || val.is_a?(DateTime)

      Date.parse(val.to_s)
    rescue Date::Error
      nil
    end
  end
end

# Monkey-patch for capitalize_first_letter used in derive_product_name
class String
  def capitalize_first_letter
    return self if empty?

    self[0].upcase + self[1..]
  end
end
