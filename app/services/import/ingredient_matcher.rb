# frozen_string_literal: true

module Import
  class IngredientMatcher
    ARTICLES = /\b(le|la|les|l'|de|du|des|d'|un|une|au|aux)\b/i.freeze

    def self.call(recipe_ingredients, products, output_path)
      new(recipe_ingredients, products, output_path).call
    end

    def initialize(recipe_ingredients, products, output_path)
      @ingredients = recipe_ingredients.uniq
      @products = products
      @output_path = output_path
    end

    def call
      puts "  Matching #{@ingredients.size} ingrédients contre #{@products.size} produits..."

      mappings = @ingredients.map { |name| match(name) }
      write_csv!(mappings)

      matched = mappings.count { |m| m[:product_id].present? }
      puts "  #{matched}/#{@ingredients.size} ingrédients matchés."
      puts "  CSV généré : #{@output_path}"

      mappings
    end

    private

    def match(ingredient_name)
      result = try_exact(ingredient_name) ||
               try_normalized(ingredient_name) ||
               try_substring(ingredient_name) ||
               try_levenshtein(ingredient_name)

      if result
        result.merge(ingredient: ingredient_name)
      else
        { ingredient: ingredient_name, product_name: "", confidence: "none", method: "aucun", product_id: nil }
      end
    end

    def try_exact(name)
      key = name.downcase.strip
      product = @products.values.find { |p| p.name.downcase.strip == key }
      return nil unless product

      { product_name: product.name, confidence: "high", method: "exact", product_id: product.id }
    end

    def try_normalized(name)
      norm = normalize(name)
      product = @products.values.find { |p| normalize(p.name) == norm }
      return nil unless product

      { product_name: product.name, confidence: "high", method: "normalized", product_id: product.id }
    end

    def try_substring(name)
      norm = normalize(name)
      return nil if norm.length < 4

      product = @products.values.find { |p| normalize(p.name).include?(norm) || norm.include?(normalize(p.name)) }
      return nil unless product

      { product_name: product.name, confidence: "medium", method: "substring", product_id: product.id }
    end

    def try_levenshtein(name)
      norm = normalize(name)
      return nil if norm.length < 3

      best = nil
      best_dist = Float::INFINITY

      @products.values.each do |product|
        pnorm = normalize(product.name)
        dist = levenshtein(norm, pnorm)
        threshold = [norm.length, pnorm.length].max * 0.35

        if dist < threshold && dist < best_dist
          best = product
          best_dist = dist
        end
      end

      return nil unless best

      { product_name: best.name, confidence: "low", method: "levenshtein", product_id: best.id }
    end

    def normalize(str)
      str.to_s
         .unicode_normalize(:nfkd)
         .gsub(/[\u0300-\u036f]/, "")
         .downcase
         .gsub(ARTICLES, "")
         .gsub(/[^a-z0-9\s]/, "")
         .squish
    end

    def levenshtein(a, b)
      m = a.length
      n = b.length
      d = Array.new(m + 1) { |i| i }

      (1..n).each do |j|
        prev = d[0]
        d[0] = j
        (1..m).each do |i|
          cost = a[i - 1] == b[j - 1] ? 0 : 1
          temp = d[i]
          d[i] = [d[i] + 1, d[i - 1] + 1, prev + cost].min
          prev = temp
        end
      end

      d[m]
    end

    def write_csv!(mappings)
      FileUtils.mkdir_p(File.dirname(@output_path))

      CSV.open(@output_path, "wb", col_sep: ";") do |csv|
        csv << %w[ingredient_recette produit_match confiance methode product_id]
        mappings.each do |m|
          csv << [m[:ingredient], m[:product_name], m[:confidence], m[:method], m[:product_id]]
        end
      end
    end
  end
end
