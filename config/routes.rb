Rails.application.routes.draw do
  get 'word_entries/index'
  get 'word_entries/new'
  get 'word_entries/edit'
  resources :folders do
    resources :wordbooks do
      resources :word_entries
    end
  end

  namespace :users do
    resource :settings, only: [:show]
    patch :update_account, to: "settings#update_account"
    patch :update_profile, to: "settings#update_profile"
  end

  devise_for :users
  root to: "home#index"
end