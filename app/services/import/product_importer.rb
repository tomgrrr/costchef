# frozen_string_literal: true

module Import
  class ProductImporter
    def self.call(spreadsheet, user, suppliers)
      new(spreadsheet, user, suppliers).call
    end

    def initialize(spreadsheet, user, suppliers)
      @spreadsheet = spreadsheet
      @user = user
      @suppliers = suppliers
    end

    def call
      puts "  Import des produits et achats..."

      products = {}
      purchase_count = 0

      TabConfig.sheets.each do |sheet_name, config|
        config[:sections].each do |section|
          lines = TabParser.call(@spreadsheet, sheet_name, section)
          lines.each do |line|
            product = find_or_create_product!(line, products)
            create_purchase!(product, line)
            purchase_count += 1
          end
        end
      end

      recalculate_averages!(products)

      puts "  #{products.size} produit(s), #{purchase_count} achat(s) importés."
      products
    end

    private

    def find_or_create_product!(line, products)
      name = line[:product_name]
      base_unit = line[:base_unit]
      key = "#{name}|#{base_unit}"

      return products[key] if products[key]

      attrs = { name: name, base_unit: base_unit }
      attrs[:unit_weight_kg] = piece_weight(name) if base_unit == "piece"

      product = @user.products.find_or_initialize_by(name: name)
      product.assign_attributes(attrs)
      product.save!

      products[key] = product
      product
    end

    def create_purchase!(product, line)
      supplier = @suppliers[line[:supplier_name]]
      return unless supplier

      ProductPurchase.create!(
        product: product,
        supplier: supplier,
        package_quantity: line[:quantity],
        package_price: line[:price],
        package_unit: line[:package_unit],
        active: true
      )
    end

    def piece_weight(name)
      TabConfig.piece_weight(name) || 0.050
    end

    def recalculate_averages!(products)
      puts "  Recalcul des prix moyens..."
      products.each_value do |product|
        Products::AvgPriceRecalculator.call(product)
      end
    end
  end
end
