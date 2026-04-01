# frozen_string_literal: true

module Import
  class TabConfig
    IGNORED_SHEETS = %w[Moyenne Revente].freeze

    # Supplier name normalization map (lowercase key → canonical name)
    SUPPLIER_ALIASES = {
      "ds" => "DS restauration",
      "abp" => "ABP",
      "apb" => "ABP",
      "sysco" => "Sysco",
      "transgourmet" => "Transgourmet",
      "france frais" => "France frais",
      "jallet" => "Jallet",
      "metro" => "Metro",
      "cap traiteur" => "Cap traiteur",
      "cdp" => "CdP",
      "colin" => "Colin",
      "magpra" => "Magpra",
      "coboma" => "Coboma",
      "cantal salaisons" => "Cantal salaisons",
      "limoujoux" => "Limoujoux",
      "tradival" => "Tradival",
      "gaec fournier" => "GAEC fournier",
      "délices des bois" => "Délices des bois",
      "delices des bois" => "Délices des bois",
      "allier volailles" => "Allier volailles",
      "ronchetti" => "Ronchetti",
      "dischamps" => "Dischamps",
      "trapon champignons" => "Trapon champignons",
      "moulin de massagettes" => "Moulin de massagettes",
      "fournil de jean" => "Fournil de jean",
      "la bovida" => "La bovida",
      "grelet" => "Grelet",
      "ribeyron" => "Ribeyron",
      "sas frais livré" => "SAS frais livré"
    }.freeze

    # Unit weight lookup for piece-based products (in kg)
    PIECE_WEIGHTS = {
      "Oeuf poché" => 0.040,
      "Oeuf entier" => 0.050,
      "Oeuf extra frais" => 0.050
    }.freeze

    # Standard layout: col 1 = product name, col 2 = date, etc.
    STANDARD_COLS = {
      product: 1, date: 2, quantity: 3, price: 4,
      supplier: 5, price_per_kg: 6, designation: 7
    }.freeze

    # No-product-col layout: col 1 = date (no product name column)
    NO_PRODUCT_COLS = {
      date: 1, quantity: 2, price: 3,
      supplier: 4, price_per_kg: 5, designation: 6
    }.freeze

    # Config per sheet. Offsets calibrated from rake import:inspect.
    # no_product_col: true = sheet starts with Date column, no product name
    # default_product: fallback product name when col 1 is empty
    SHEETS = {
      # --- Standard sheets (product name in col 1) ---
      "Fruits" => { sections: [{ col_offset: 0, base_unit: "kg" }] },
      "Légumes" => { sections: [{ col_offset: 0, base_unit: "kg" }] },
      "Poissons" => { sections: [{ col_offset: 0, base_unit: "kg" }] },
      "Produits laitiers" => { sections: [{ col_offset: 0, base_unit: "kg" }] },
      "Riz" => { sections: [{ col_offset: 0, base_unit: "kg" }] },
      "Pâtes" => { sections: [{ col_offset: 0, base_unit: "kg" }] },
      "Coques" => { sections: [{ col_offset: 0, base_unit: "kg" }] },
      "Epices" => { sections: [{ col_offset: 0, base_unit: "kg" }] },
      "Alcool" => { sections: [{ col_offset: 0, base_unit: "l" }] },
      "Emballage" => { sections: [{ col_offset: 0, base_unit: "piece" }] },

      # --- No-product-col sheets (Date in col 1) ---
      "Farine" => { sections: [{ col_offset: 0, base_unit: "kg", no_product_col: true }] },
      "PuréeS" => { sections: [{ col_offset: 0, base_unit: "kg", no_product_col: true }] },
      "Sucre" => { sections: [{ col_offset: 0, base_unit: "kg", no_product_col: true }] },
      "Huiles" => { sections: [{ col_offset: 0, base_unit: "l", no_product_col: true }] },
      "Sauce" => { sections: [{ col_offset: 0, base_unit: "kg", no_product_col: true }] },
      "Autre" => { sections: [{ col_offset: 0, base_unit: "kg", no_product_col: true }] },

      # --- Multi-section sheets (offsets from inspect) ---
      "Viandes" => {
        sections: [
          { col_offset: 0, base_unit: "kg", label: "Porc" },
          { col_offset: 9, base_unit: "kg", label: "Boeuf" },
          { col_offset: 18, base_unit: "kg", label: "Volaille" }
        ]
      },
      "Oeuf" => {
        sections: [
          { col_offset: 0, base_unit: "piece", label: "Solide", default_product: "Oeuf solide" },
          { col_offset: 8, base_unit: "kg", label: "Liquide", default_product: "Oeuf liquide entier" }
        ]
      },
      "Patisseries" => {
        sections: [
          { col_offset: 0, base_unit: "piece", label: "Patisseries" },
          { col_offset: 8, base_unit: "piece", label: "Pain" },
          { col_offset: 16, base_unit: "kg", label: "Chapelure" }
        ]
      }
    }.freeze

    def self.sheets
      SHEETS
    end

    def self.ignored?(sheet_name)
      IGNORED_SHEETS.include?(sheet_name)
    end

    def self.config_for(sheet_name)
      SHEETS[sheet_name]
    end

    def self.normalize_supplier(name)
      return nil if name.blank?

      stripped = name.to_s.strip.squish
      SUPPLIER_ALIASES[stripped.downcase] || stripped
    end

    def self.piece_weight(product_name)
      PIECE_WEIGHTS[product_name]
    end

    def self.cols_for(section)
      base = section[:no_product_col] ? NO_PRODUCT_COLS : STANDARD_COLS
      offset = section[:col_offset] || 0
      base.transform_values { |v| v + offset }
    end
  end
end
