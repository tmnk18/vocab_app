Rails.application.routes.draw do
  get 'extractions/new'

  resources :folders do
    # 単語帳一覧取得（AJAX用）
    get :wordbooks, on: :member

    resources :wordbooks do
      collection do
        get :move
        patch :move_wordbooks, as: :move_wordbooks
      end

      resources :word_entries do
        collection do
          get :move
          patch :move_entries
          delete :delete_entries
        end
      end
    end
  end

  resources :wordbooks do
    collection do
      get :public_index
      get :copy_select
      post :copy_wordbooks
    end
    resource :like, only: [:create, :destroy]
    resources :word_entries, only: [:index, :show]
  end

  resources :extractions, only: [:new] do
    collection do
      post :tokenize
      post :fetch_meanings
      get :fetch_meanings
      post :select_target
      post :register
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