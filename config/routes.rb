Rails.application.routes.draw do
  get 'extractions/new'
  resources :folders do
    # 単語帳一覧取得（AJAX用）
    get :wordbooks, on: :member
  
    resources :wordbooks do
      collection do
        get :move                             # 単語帳の移動先選択ページ表示
        patch :move_wordbooks, as: :move_wordbooks # パスヘルパー名を短く設定
      end
  
      resources :word_entries do
        collection do
          get :move             # 単語の移動先選択ページ表示
          patch :move_entries   # 単語の移動処理
          delete :delete_entries # 単語の一括削除処理
        end
      end
    end
  end

  resources :wordbooks do
    collection do
      get :public_index  # 公開単語帳一覧ページ
      get :copy_select  # チェック後にコピー先を選ぶ画面
      post :copy_wordbooks  # コピー実行アクション
    end
    resource :like, only: [:create, :destroy] # いいね機能
    resources :word_entries, only: [:index, :show]
  end

  resources :extractions, only: [:new] do
    collection do
      post :tokenize      # 入力した英文単語に分割
      post :fetch_meanings # 選択単語の意味取得
      post :select_target  # 追加先の単語帳選択
      post :register       # 単語帳に登録
    end
  end

  post "extractions/confirm", to: "extractions#fetch_meanings"
  get  "extractions/select_target", to: "extractions#select_target"
  post "extractions/register", to: "extractions#register"

  namespace :users do
    resource :settings, only: [:show]
    patch :update_account, to: "settings#update_account"
    patch :update_profile, to: "settings#update_profile"
  end

  devise_for :users
  root to: "home#index"
end