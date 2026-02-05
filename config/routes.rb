# frozen_string_literal: true

Rails.application.routes.draw do
  # PRD Module 1 : Devise sans inscription publique
  # L'inscription se fait uniquement via invitation admin
  devise_for :users, skip: [:registrations]

  # PRD Module 1 : Inscription via invitation sécurisée
  get 'signup', to: 'signups#new', as: :signup
  post 'signup', to: 'signups#create'

  # PRD Module 1 : Page statique "Abonnement requis"
  get 'subscription_required', to: 'pages#subscription_required', as: :subscription_required

  # PRD Module 1 : Administration
  # Accès uniquement aux admins (vérifié dans Admin::BaseController)
  namespace :admin do
    resources :users, only: %i[index update]
    resources :invitations, only: %i[index new create]
  end

  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Racine de l'application (temporaire - sera remplacée par le dashboard)
  root 'pages#home'
end
