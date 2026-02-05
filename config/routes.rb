Rails.application.routes.draw do
  devise_for :users

  # PRD Module 1 : Page statique "Abonnement requis"
  get "subscription_required", to: "pages#subscription_required", as: :subscription_required

  # PRD Module 1 : Administration des utilisateurs
  # Accès uniquement aux admins (vérifié dans Admin::BaseController)
  namespace :admin do
    resources :users, only: [:index, :update]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Racine de l'application (temporaire - sera remplacée par le dashboard)
  root "pages#home"
end
