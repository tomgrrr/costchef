# frozen_string_literal: true

Rails.application.routes.draw do
  # ============================================
  # PRD Module 1 : Authentification
  # ============================================
  devise_for :users, skip: [:registrations]

  # Inscription via invitation sécurisée
  get 'signup', to: 'signups#new', as: :signup
  post 'signup', to: 'signups#create'

  # Page statique "Abonnement requis"
  get 'subscription_required', to: 'pages#subscription_required', as: :subscription_required

  # ============================================
  # PRD Module 1 : Administration
  # ============================================
  namespace :admin do
    resources :users, only: %i[index update]
    resources :invitations, only: %i[index new create]
  end

  # ============================================
  # PRD Module 2 : Référentiel Produits
  # ============================================
  resources :products do
    # PRD Module 4 : Conditionnements d'achat (nested)
    resources :product_purchases, only: %i[create update destroy] do
      member do
        patch :toggle_active
      end
    end
  end

  # ============================================
  # PRD Module 3 : Fournisseurs
  # ============================================
  resources :suppliers do
    member do
      patch :deactivate
      delete :force_destroy
    end
  end

  # ============================================
  # PRD Module 5 : Recettes
  # ============================================
  resources :recipes do
    # PRD : Composants polymorphes (produit ou sous-recette)
    resources :recipe_components, only: %i[create destroy]
    member do
      post :duplicate
    end
  end

  # ============================================
  # PRD Module 7 : Paramètres utilisateur
  # ============================================
  resource :settings, only: %i[show update] do
    # 7a. Coefficient multiplicateur (dans settings#update)
    # 7b. Barquettes plastique
    resources :tray_sizes, only: %i[index create update destroy]
  end

  # ============================================
  # PRD Module 8 & 9 : Plat du Jour
  # ============================================
  resources :daily_specials, only: %i[index create update destroy]

  # ============================================
  # Health check & Root
  # ============================================
  get 'up' => 'rails/health#show', as: :rails_health_check
  root 'pages#home'
end
