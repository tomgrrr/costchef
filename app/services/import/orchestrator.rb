# frozen_string_literal: true

module Import
  class Orchestrator
    PRODUCTS_FILE = File.expand_path("~/Downloads/Prix moyen Lassalas revu avec moyenne (3).ods").freeze
    RECIPES_FILE = File.expand_path("~/Downloads/Recettes 19 mars 26 (2).ods").freeze
    USER_EMAIL = "dp.lassalas@outlook.fr"
    MAPPING_PATH = Rails.root.join("tmp/import/ingredient_mapping.csv").to_s.freeze

    def self.import_products!
      new.import_products!
    end

    def self.import_recipes!
      new.import_recipes!
    end

    def self.import_all!
      new.import_all!
    end

    def import_products!
      user = find_user!
      spreadsheet = OdsReader.call(PRODUCTS_FILE)

      puts "=== Import produits pour #{user.email} ==="

      Purger.call(user)
      suppliers = SupplierExtractor.call(spreadsheet, user)
      products = ProductImporter.call(spreadsheet, user, suppliers)
      generate_mapping!(products)

      print_summary(user)
    end

    def import_recipes!
      user = find_user!

      puts "=== Import recettes pour #{user.email} ==="

      RecipeImporter.call(user, MAPPING_PATH)
      print_recipe_summary(user)
    end

    def import_all!
      import_products!
      import_recipes!
    end

    private

    def find_user!
      user = User.find_by!(email: USER_EMAIL)
      puts "Utilisateur trouvé : #{user.first_name} #{user.last_name} (#{user.email})"
      user
    rescue ActiveRecord::RecordNotFound
      raise "Utilisateur #{USER_EMAIL} introuvable. Exécutez `bin/rails db:seed` d'abord."
    end

    def generate_mapping!(products)
      recipe_ingredients = collect_recipe_ingredients
      IngredientMatcher.call(recipe_ingredients, products, MAPPING_PATH)
    end

    def collect_recipe_ingredients
      parsed = RecipeParser.call(RECIPES_FILE)
      parsed.flat_map { |r| r[:components].map { |c| c[:name] } }.uniq
    end

    def print_summary(user)
      puts "\n=== Résumé import produits ==="
      puts "  Fournisseurs : #{user.suppliers.count}"
      puts "  Produits     : #{user.products.count}"
      puts "  Achats       : ProductPurchase total = #{ProductPurchase.joins(:product).where(products: { user_id: user.id }).count}"

      zero_price = user.products.where(avg_price_per_kg: 0).count
      puts "  Produits à prix 0 : #{zero_price}" if zero_price > 0

      puts "\n  Mapping CSV : #{MAPPING_PATH}"
      puts "  => Corrigez le CSV puis lancez `rake import:recipes`"
    end

    def print_recipe_summary(user)
      puts "\n=== Résumé import recettes ==="
      puts "  Recettes totales : #{user.recipes.count}"
      puts "  Sous-recettes    : #{user.recipes.where(sellable_as_component: true).count}"
      puts "  Recettes         : #{user.recipes.where(sellable_as_component: false).count}"

      with_cost = user.recipes.where("cached_cost_per_kg > 0").count
      puts "  Avec coût calculé : #{with_cost}"
    end
  end
end
