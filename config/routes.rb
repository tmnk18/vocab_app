Rails.application.routes.draw do
  resources :folders do
    resources :wordbooks do
      collection do
        get :move           # 単語帳の移動先選択ページ表示
        patch :move_wordbooks, as: :move_wordbooks # パスヘルパー名を短く設定
      end
  
      resources :word_entries do
        collection do
          get :move           # 単語の移動先選択ページ表示
          patch :move_entries # 単語の移動処理
          delete :delete_entries # 単語の一括削除処理
        end
      end
    end
  end

  resources :wordbooks do
    collection do
      get :public_index  # 公開単語帳一覧ページ
    end
    resource :like, only: [:create, :destroy] # いいね機能
    resources :word_entries, only: [:index, :show]
  end

  namespace :users do
    resource :settings, only: [:show]
    patch :update_account, to: "settings#update_account"
    patch :update_profile, to: "settings#update_profile"
  end

  devise_for :users
  root to: "home#index"
end