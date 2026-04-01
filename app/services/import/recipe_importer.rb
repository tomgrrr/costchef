# frozen_string_literal: true

module Import
  class RecipeImporter
    def self.call(user, mapping_path)
      new(user, mapping_path).call
    end

    def initialize(user, mapping_path)
      @user = user
      @mapping_path = mapping_path
    end

    def call
      validate_mapping!

      purge_recipes!

      @mapping = load_mapping
      parsed = RecipeParser.call(Import::Orchestrator::RECIPES_FILE)

      subrecipes_data = parsed.select { |r| r[:is_subrecipe] }
      recipes_data = parsed.reject { |r| r[:is_subrecipe] }

      # Pass 1: Create all recipes as empty shells
      create_placeholder_subrecipes!(parsed)
      create_all_recipes!(subrecipes_data, recipes_data)

      # Pass 2: Add components to all recipes
      add_all_components!(subrecipes_data, recipes_data)

      recalculate_all!

      total = @user.recipes.count
      puts "  #{total} recettes importées au total."
    end

    private

    def validate_mapping!
      unless File.exist?(@mapping_path)
        raise ArgumentError,
              "Fichier de mapping introuvable : #{@mapping_path}\n" \
              "Exécutez d'abord `rake import:products` puis corrigez le CSV."
      end
    end

    def purge_recipes!
      puts "  Purge des recettes existantes..."
      recipe_ids = @user.recipes.pluck(:id)
      count = RecipeComponent.where(parent_recipe_id: recipe_ids).delete_all
      puts "    #{count} composants supprimés"
      count = @user.recipes.delete_all
      puts "    #{count} recettes supprimées"
    end

    def load_mapping
      products = {}
      subrecipes = {}
      ignored = 0

      CSV.foreach(@mapping_path, col_sep: ";", headers: true) do |row|
        ingredient = row["ingredient_recette"]&.strip
        next if ingredient.blank?

        confidence = row["confiance"]&.strip
        key = ingredient.downcase

        if confidence == "ignore"
          ignored += 1
          next
        end

        if confidence == "subrecipe"
          subrecipes[key] = true
          next
        end

        product_id = row["product_id"]
        next if product_id.blank?

        products[key] = product_id.to_i
      end

      puts "  #{products.size} produits + #{subrecipes.size} sous-recettes + #{ignored} ignorés chargés depuis #{@mapping_path}"
      { products: products, subrecipes: subrecipes }
    end

    def create_placeholder_subrecipes!(parsed)
      referenced = collect_subrecipe_references(parsed)
      defined = parsed.select { |r| r[:is_subrecipe] }.map { |r| r[:name].downcase }

      missing = referenced - defined
      count = 0

      missing.each do |name|
        display_name = name.split.map(&:capitalize).join(" ")
        @user.recipes.find_or_create_by!(name: display_name) do |r|
          r.sellable_as_component = true
          r.cooking_loss_percentage = 0
        end
        count += 1
      end

      puts "  #{count} sous-recettes placeholder créées." if count > 0
    end

    def collect_subrecipe_references(parsed)
      refs = Set.new
      parsed.each do |recipe|
        recipe[:components].each do |comp|
          key = comp[:name].downcase
          refs << key if is_subrecipe_ingredient?(key)
        end
      end
      refs.to_a
    end

    def create_all_recipes!(subrecipes_data, recipes_data)
      puts "  Création de #{subrecipes_data.size} sous-recettes + #{recipes_data.size} recettes..."

      subrecipes_data.each { |data| find_or_create_recipe!(data, sellable: true) }
      recipes_data.each { |data| find_or_create_recipe!(data, sellable: false) }
    end

    def add_all_components!(subrecipes_data, recipes_data)
      puts "  Ajout des composants..."

      (subrecipes_data + recipes_data).each do |data|
        recipe = @user.recipes.find_by!(name: data[:name])
        import_components!(recipe, data[:components])
      end
    end

    def find_or_create_recipe!(data, sellable:)
      recipe = @user.recipes.find_or_initialize_by(name: data[:name])
      recipe.assign_attributes(
        description: data[:description],
        cooking_loss_percentage: data[:cooking_loss_pct] || 0,
        sellable_as_component: sellable
      )
      recipe.save!
      recipe
    end

    def import_components!(recipe, components)
      components.each do |comp|
        key = comp[:name].downcase

        if is_subrecipe_ingredient?(key)
          link_subrecipe_component!(recipe, comp)
        elsif @mapping[:products][key]
          link_product_component!(recipe, comp)
        end
      end
    end

    def is_subrecipe_ingredient?(key)
      key.match?(RecipeParser::SUBRECIPE_PATTERN) || @mapping[:subrecipes][key]
    end

    def link_subrecipe_component!(recipe, comp)
      subrecipe = find_subrecipe(comp[:name])

      unless subrecipe
        # Try adding "sous recette" suffix for CSV-mapped subrecipes
        subrecipe = find_subrecipe("#{comp[:name]} sous recette")
      end

      unless subrecipe
        puts "    WARN: sous-recette introuvable pour '#{comp[:name]}' dans #{recipe.name}"
        return
      end

      ensure_sellable!(subrecipe)

      qty_kg = Units::Converter.to_kg(comp[:quantity], comp[:unit], product: nil)
      return if qty_kg <= 0

      recipe.recipe_components.find_or_create_by!(
        component_type: "Recipe",
        component_id: subrecipe.id
      ) do |rc|
        rc.quantity_kg = qty_kg
        rc.quantity_unit = comp[:unit]
      end
    end

    def link_product_component!(recipe, comp)
      product_id = @mapping[:products][comp[:name].downcase]
      return unless product_id

      product = Product.find_by(id: product_id)
      return unless product

      qty_kg = Units::Converter.to_kg(comp[:quantity], comp[:unit], product: product)
      return if qty_kg <= 0

      recipe.recipe_components.find_or_create_by!(
        component_type: "Product",
        component_id: product.id
      ) do |rc|
        rc.quantity_kg = qty_kg
        rc.quantity_unit = comp[:unit]
      end
    end

    def find_subrecipe(name)
      normalized = normalize_subrecipe_name(name)

      @user.recipes.find_by(name: name) ||
        @user.recipes.where("LOWER(name) = ?", name.downcase).first ||
        @user.recipes.where("LOWER(name) = ?", normalized).first ||
        fuzzy_find_subrecipe(normalized)
    end

    def ensure_sellable!(recipe)
      return if recipe.sellable_as_component?

      recipe.update_columns(sellable_as_component: true, has_tray: false, sold_by_unit: false)
      puts "    FIX: #{recipe.name} marquée sellable_as_component"
    end

    def normalize_subrecipe_name(name)
      name.downcase
          .gsub("pate ", "pâte ")
          .gsub("feuilletés", "feuilletée")
          .gsub("brisee", "brisée")
          .gsub("rappées", "rapées")
          .gsub("rappees", "rapees")
    end

    def fuzzy_find_subrecipe(normalized)
      @user.recipes.find_each do |r|
        return r if r.name.downcase == normalized
        return r if strip_accents(r.name.downcase) == strip_accents(normalized)
      end
      nil
    end

    def strip_accents(str)
      str.gsub("é", "e").gsub("è", "e").gsub("ê", "e")
         .gsub("â", "a").gsub("à", "a")
         .gsub("î", "i").gsub("ô", "o").gsub("û", "u")
    end

    def recalculate_all!
      puts "  Recalcul de toutes les recettes..."

      # Subrecipes first (bottom-up)
      @user.recipes.where(sellable_as_component: true).find_each do |recipe|
        Recipes::Recalculator.call(recipe)
      end

      # Then main recipes
      @user.recipes.where(sellable_as_component: false).find_each do |recipe|
        Recipes::Recalculator.call(recipe)
      end
    end
  end
end
