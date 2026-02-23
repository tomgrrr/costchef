# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  get  '/signup', to: 'signups#new',    as: :signup
  post '/signup', to: 'signups#create'

  get   '/subscription_required', to: 'pages#subscription_required',
        as: :subscription_required

  root to: 'pages#home'

  namespace :admin do
    resources :users,       only: %i[index update]
    resources :invitations, only: %i[index new create]
  end

  resources :suppliers, except: [:show] do
    member do
      post :activate
      post :deactivate
    end
  end

  resources :products, except: [:show]

  resources :product_purchases, only: %i[create update destroy] do
    member do
      post :toggle_active
    end
  end

  get 'recipes/tarifs', to: 'recipes#tarifs', as: 'tarifs_recipes'

  resources :recipes do
    member do
      post :duplicate
    end
    resources :recipe_components, only: %i[create update destroy]
  end

  resources :tray_sizes, only: %i[index new create edit update destroy]

  get   '/settings', to: 'settings#edit',   as: :settings
  patch '/settings', to: 'settings#update'

  resources :daily_specials, only: %i[index create update destroy]
end
