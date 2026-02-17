# frozen_string_literal: true

class PagesController < ApplicationController
  # PRD Module 1 : Page statique "Abonnement requis"
  # Exceptions : cette page doit être accessible sans abonnement actif
  skip_before_action :ensure_subscription!, only: [:subscription_required]

  # GET /
  # Dashboard avec statistiques
  def home
    @products_count = current_user.products.count
    @recipes_count = current_user.recipes.count
    @recent_recipes = current_user.recipes
                                  .includes(:recipe_components)
                                  .order(updated_at: :desc)
                                  .limit(5)

    # Calcul du coût moyen des recettes
    recipes_with_cost = current_user.recipes.where.not(cached_total_cost: nil)
    @average_cost = recipes_with_cost.any? ? recipes_with_cost.average(:cached_total_cost).round(2) : 0

    # Top produits utilisés
    @top_products = current_user.products
                                .joins(:recipe_components)
                                .group('products.id')
                                .order('COUNT(recipe_components.id) DESC')
                                .limit(3)
                                .select('products.*, COUNT(recipe_components.id) as recipes_count')
  end

  # GET /subscription_required
  # Affiche un message indiquant que l'abonnement est inactif
  def subscription_required
    # Redirige vers la racine si l'utilisateur a déjà un abonnement actif
    redirect_to root_path if current_user.subscription_active?
  end
end
