Rails.application.routes.draw do
  resources :folders do
    resources :wordbooks do
      resources :word_entries do
        collection do
          get :move  # 移動先選択ページ表示
          patch :move_entries  # 移動処理
          delete :delete_entries # 削除処理 
        end
      end
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