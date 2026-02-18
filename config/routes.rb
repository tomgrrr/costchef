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

  resources :suppliers do
    member do
      patch  :deactivate
      delete :force_destroy
    end
  end

  resources :products do
    resources :product_purchases, only: %i[create update destroy] do
      member do
        patch :toggle_active
      end
    end
  end

  resources :recipes do
    member do
      post :duplicate
    end
    resources :recipe_components, only: %i[create destroy]
  end

  resources :tray_sizes

  get   '/settings', to: 'settings#edit',   as: :settings
  patch '/settings', to: 'settings#update'

  resources :daily_specials, only: %i[index create update destroy]
end
