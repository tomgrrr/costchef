# frozen_string_literal: true

module Import
  class Purger
    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      puts "  Purge des données de #{@user.email}..."

      ActiveRecord::Base.transaction do
        purge_in_order!
      end

      puts "  Purge terminée."
    end

    private

    def purge_in_order!
      counts = {}

      counts[:recipe_components] = delete_recipe_components!
      counts[:recipes] = delete_recipes!
      counts[:product_purchases] = delete_product_purchases!
      counts[:products] = delete_products!
      counts[:suppliers] = delete_suppliers!
      counts[:tray_sizes] = delete_tray_sizes!

      counts.each { |k, v| puts "    #{k}: #{v} supprimé(s)" }
    end

    def delete_recipe_components!
      recipe_ids = @user.recipes.pluck(:id)
      RecipeComponent.where(parent_recipe_id: recipe_ids).delete_all
    end

    def delete_recipes!
      @user.recipes.delete_all
    end

    def delete_product_purchases!
      product_ids = @user.products.pluck(:id)
      ProductPurchase.where(product_id: product_ids).delete_all
    end

    def delete_products!
      @user.products.delete_all
    end

    def delete_suppliers!
      @user.suppliers.delete_all
    end

    def delete_tray_sizes!
      @user.tray_sizes.delete_all
    end
  end
end
