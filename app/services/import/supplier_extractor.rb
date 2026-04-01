# frozen_string_literal: true

module Import
  class SupplierExtractor
    def self.call(spreadsheet, user)
      new(spreadsheet, user).call
    end

    def initialize(spreadsheet, user)
      @spreadsheet = spreadsheet
      @user = user
    end

    def call
      puts "  Extraction des fournisseurs..."

      names = collect_supplier_names
      suppliers = create_suppliers!(names)

      puts "  #{suppliers.size} fournisseur(s) créé(s)."
      suppliers
    end

    private

    def collect_supplier_names
      names = Set.new

      TabConfig.sheets.each do |sheet_name, config|
        config[:sections].each do |section|
          lines = TabParser.call(@spreadsheet, sheet_name, section)
          lines.each { |l| names << l[:supplier_name] if l[:supplier_name].present? }
        end
      end

      names
    end

    def create_suppliers!(names)
      result = {}

      names.each do |name|
        supplier = @user.suppliers.find_or_create_by!(name: name)
        result[name] = supplier
      end

      result
    end
  end
end
