# frozen_string_literal: true

module Recalculations
  # PRD Section 7.4 : Dispatcher
  #
  # Rôle : Orchestrer les recalculs multi-entités en réponse à un événement métier.
  # C'est le SEUL service autorisé à déclencher des recalculs en chaîne.
  #
  # Principe : aucun callback Active Record. Les controllers appellent explicitement le Dispatcher.
  #
  # Contrat : le Dispatcher ne persiste jamais un ProductPurchase. Les achats doivent être
  # calculés (PricePerKgCalculator) et sauvegardés par le contrôleur AVANT d'appeler le Dispatcher.
  #
  # Événements gérés :
  # - A : product_purchase_changed (create/update/destroy/toggle active)
  # - B : recipe_component_changed (create/update/destroy)
  # - C : recipe_changed (update cooking_loss_pct / has_tray / tray_size_id)
  # - D : supplier_force_destroyed (suppression forcée avec cascade)
  #
  # Ordre de recalcul global : conditionnement → produit (avg) → recettes directes → recettes parentes
  #
  class Dispatcher
    # =========================================================================
    # ÉVÉNEMENT A : Changement sur un conditionnement d'achat
    # =========================================================================
    #
    # Appelé après create/update/destroy/toggle d'un ProductPurchase.
    # L'achat doit être déjà calculé et persisté par le contrôleur.
    #
    # Ordre strict (PRD Section 7.4) :
    # 1. AvgPriceRecalculator.call(purchase.product)
    # 2. Trouver les recettes impactées via recipe_components
    # 3. Recalculator.call(recipe) pour chaque recette impactée
    # 4. Propager aux recettes parentes (1 niveau)
    #
    def self.product_purchase_changed(purchase, product: nil)
      new.product_purchase_changed(purchase, product: product)
    end

    def product_purchase_changed(purchase, product: nil)
      target_product = product || purchase&.product
      return unless target_product

      Products::AvgPriceRecalculator.call(target_product)
      recalculate_recipes_using_product(target_product)
    end

    # =========================================================================
    # ÉVÉNEMENT B : Changement sur un composant de recette
    # =========================================================================
    #
    # Appelé après create/update/destroy d'un RecipeComponent
    #
    # Ordre (PRD Section 7.4) :
    # 1. Recalculator.call(component.parent_recipe)
    # 2. Si parent_recipe est sous-recette : recalculer les recettes parentes
    #
    def self.recipe_component_changed(recipe)
      new.recipe_component_changed(recipe)
    end

    def recipe_component_changed(recipe)
      return unless recipe

      # Étape 1 : Recalculer la recette
      Recipes::Recalculator.call(recipe)

      # Étape 2 : Propager si sous-recette
      propagate_to_parent_recipes(recipe)
    end

    # =========================================================================
    # ÉVÉNEMENT C : Changement sur une recette (cooking_loss, tray, etc.)
    # =========================================================================
    #
    # Appelé après update d'une Recipe (pour les champs qui impactent les calculs)
    #
    # Ordre (PRD Section 7.4) :
    # 1. Recalculator.call(recipe)
    # 2. Si recipe est sous-recette : recalculer les recettes parentes
    #
    def self.recipe_changed(recipe)
      new.recipe_changed(recipe)
    end

    def recipe_changed(recipe)
      return unless recipe

      # Étape 1 : Recalculer la recette
      Recipes::Recalculator.call(recipe)

      # Étape 2 : Propager si sous-recette
      propagate_to_parent_recipes(recipe)
    end

    # =========================================================================
    # ÉVÉNEMENT D : Suppression forcée d'un fournisseur
    # =========================================================================
    #
    # Appelé après Supplier#force_destroy!
    # Les achats ont été supprimés, il faut recalculer les produits impactés
    #
    def self.supplier_force_destroyed(product_ids)
      new.supplier_force_destroyed(product_ids)
    end

    def supplier_force_destroyed(product_ids)
      return if product_ids.blank?

      # Recalculer chaque produit impacté
      Product.where(id: product_ids).find_each do |product|
        Products::AvgPriceRecalculator.call(product)
        recalculate_recipes_using_product(product)
      end
    end

    # =========================================================================
    # ÉVÉNEMENT E : Recalcul complet d'un produit (utile pour les imports, etc.)
    # =========================================================================
    def self.full_product_recalculation(product)
      new.full_product_recalculation(product)
    end

    def full_product_recalculation(product)
      return unless product

      # Recalculer tous les achats du produit (le callback before_validation
      # dans ProductPurchase appelle PricePerKgCalculator automatiquement)
      product.product_purchases.find_each do |purchase|
        purchase.save!
      end

      # Recalculer le prix moyen
      Products::AvgPriceRecalculator.call(product)

      # Recalculer les recettes
      recalculate_recipes_using_product(product)
    end

    private

    # Trouve et recalcule toutes les recettes utilisant un produit
    def recalculate_recipes_using_product(product)
      # Trouver les recettes directes (qui utilisent ce produit comme composant)
      direct_recipe_ids = RecipeComponent
                          .where(component_type: 'Product', component_id: product.id)
                          .pluck(:parent_recipe_id)

      return if direct_recipe_ids.empty?

      # Recalculer chaque recette directe
      Recipe.where(id: direct_recipe_ids).find_each do |recipe|
        Recipes::Recalculator.call(recipe)

        # Propager aux recettes parentes
        propagate_to_parent_recipes(recipe)
      end
    end

    # Propage le recalcul aux recettes qui utilisent cette recette comme sous-recette
    def propagate_to_parent_recipes(recipe)
      return unless recipe.sellable_as_component?

      # Trouver les recettes parentes
      parent_recipe_ids = RecipeComponent
                          .where(component_type: 'Recipe', component_id: recipe.id)
                          .pluck(:parent_recipe_id)

      return if parent_recipe_ids.empty?

      # Recalculer chaque recette parente (1 niveau seulement, PRD D5)
      Recipe.where(id: parent_recipe_ids).find_each do |parent_recipe|
        Recipes::Recalculator.call(parent_recipe)
      end
    end
  end
end
