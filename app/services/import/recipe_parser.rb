# frozen_string_literal: true

module Import
  class RecipeParser
    SUBRECIPE_PATTERN = /sous[- ]?recette/i.freeze

    def self.call(file_path)
      new(file_path).call
    end

    def initialize(file_path)
      @file_path = file_path
    end

    def call
      spreadsheet = OdsReader.call(@file_path)
      sheet = spreadsheet.sheet(spreadsheet.sheets.first)

      recipes = parse_recipes(sheet)
      deduplicate!(recipes)

      subrecipes = recipes.select { |r| r[:is_subrecipe] }
      main_recipes = recipes.reject { |r| r[:is_subrecipe] }

      puts "  #{recipes.size} recettes parsées (#{subrecipes.size} sous-recettes, #{main_recipes.size} recettes)."
      recipes
    end

    private

    def parse_recipes(sheet)
      recipes = []
      current_recipe = nil

      (2..sheet.last_row).each do |row|
        recipe_name = cell(sheet, row, 1)

        if recipe_name.present? && recipe_name.to_s.strip.length > 1
          current_recipe = start_recipe(recipe_name, sheet, row)
          recipes << current_recipe
        elsif current_recipe
          add_component(current_recipe, sheet, row)
        end
      end

      recipes
    end

    def start_recipe(name, sheet, row)
      clean_name = name.to_s.strip.squish
      {
        name: clean_name,
        description: cell(sheet, row, 2).to_s.strip.presence,
        cooking_loss_pct: parse_loss(cell(sheet, row, 3)),
        is_subrecipe: clean_name.match?(SUBRECIPE_PATTERN),
        components: extract_components(sheet, row)
      }
    end

    def extract_components(sheet, row)
      components = []
      comp = build_component(sheet, row)
      components << comp if comp
      components
    end

    def add_component(recipe, sheet, row)
      comp = build_component(sheet, row)
      recipe[:components] << comp if comp
    end

    def build_component(sheet, row)
      name = cell(sheet, row, 4)
      return nil if name.blank?

      qty = cell(sheet, row, 5)
      unit = cell(sheet, row, 6)
      return nil if qty.blank?

      {
        name: name.to_s.strip.squish,
        quantity: qty.to_f,
        unit: normalize_unit(unit)
      }
    end

    def normalize_unit(unit)
      return "kg" if unit.blank?

      case unit.to_s.strip.downcase
      when "kg", "kilo", "kilos" then "kg"
      when "g", "gr", "gramme", "grammes" then "g"
      when "l", "litre", "litres" then "l"
      when "cl", "centilitre" then "cl"
      when "ml", "millilitre" then "ml"
      when "piece", "pièce", "pièces", "pieces", "pce", "u", "unité", "unités" then "piece"
      else "kg"
      end
    end

    def parse_loss(val)
      return 0 if val.blank?

      num = val.to_f
      # If value is like 0.15 (fraction), convert to percentage
      num = (num * 100).round(1) if num > 0 && num < 1
      num.clamp(0, 100)
    end

    def deduplicate!(recipes)
      seen = Hash.new(0)

      recipes.each do |r|
        seen[r[:name]] += 1
      end

      counter = Hash.new(0)
      recipes.each do |r|
        if seen[r[:name]] > 1
          counter[r[:name]] += 1
          r[:name] = "#{r[:name]} (#{counter[r[:name]]})" if counter[r[:name]] > 1
        end
      end
    end

    def cell(sheet, row, col)
      val = sheet.cell(row, col)
      return nil if val.nil?
      return nil if val.is_a?(String) && val.strip.empty?

      val
    end
  end
end
