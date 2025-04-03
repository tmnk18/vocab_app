Rails.application.routes.draw do
  resources :folders, only: [:index, :new, :create, :edit, :update, :destroy]
  get 'folders/index'

  namespace :users do
    resource :settings, only: [:show]
  end

  get 'home/index'
  devise_for :users
  root to: "home#index"

  patch 'users/settings/update_account', to: 'users/settings#update_account', as: :users_update_account

  namespace :users do
    patch :update_account, to: "settings#update_account"
    patch :update_profile, to: "settings#update_profile"
  end
end
