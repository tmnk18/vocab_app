# 単語帳管理用コントローラー
# 単語帳の作成、編集、削除、移動、コピー、および公開機能を担当
class WordbooksController < ApplicationController
  before_action :authenticate_user!, except: [:public_index] # 公開一覧以外はログイン必須
  before_action :set_folder, except: [:public_index, :copy_select, :copy_wordbooks] # フォルダの取得

  # 単語帳一覧を表示
  # GET /folders/:folder_id/wordbooks
  def index
    session.delete(:from_public_list) # 公開リストからの遷移フラグをクリア
    @wordbooks = @folder.wordbooks
  end

  # 公開単語帳一覧を表示
  # GET /wordbooks/public
  def public_index
    @wordbooks = Wordbook.where(is_public: true)
                      .includes(:folder => :user) # N+1問題を回避
                      .order(created_at: :desc)   # 新着順に表示
  end

  # 単語帳作成フォームを表示
  # GET /folders/:folder_id/wordbooks/new
  def new
    @wordbook = @folder.wordbooks.build
  end

  # 単語帳を作成
  # POST /folders/:folder_id/wordbooks
  def create
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.build(wordbook_params)
  
    if @wordbook.save
      redirect_to folder_wordbooks_path(@folder), notice: "単語帳を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 単語帳編集フォームを表示
  # GET /folders/:folder_id/wordbooks/:id/edit
  def edit
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.find(params[:id])
  end
  
  # 単語帳を更新
  # PATCH/PUT /folders/:folder_id/wordbooks/:id
  def update
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.find(params[:id])
    if @wordbook.update(wordbook_params)
      redirect_to folder_wordbooks_path(@folder), notice: "単語帳を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 単語帳を削除
  # DELETE /folders/:folder_id/wordbooks/:id
  def destroy
    @wordbook = @folder.wordbooks.find(params[:id])
    
    # 権限チェック - 自分のフォルダの単語帳のみ削除可能
    unless @folder.user == current_user
      return render status: :forbidden, json: { error: '権限がありません' }
    end

    @wordbook.destroy
    redirect_to folder_wordbooks_path(@folder), notice: "単語帳を削除しました"
  end

  # 単語帳の移動画面を表示
  # GET /folders/:folder_id/wordbooks/move
  def move
    @wordbooks = @folder.wordbooks
    @other_folders = current_user.folders.where.not(id: @folder.id)
  end

  # 選択された単語帳を別のフォルダに移動
  # PATCH /folders/:folder_id/wordbooks/move_wordbooks
  def move_wordbooks
    @folder = Folder.find(params[:folder_id])  # 移動元フォルダ
    target_folder = Folder.find(params[:target_folder_id])  # 移動先フォルダ
    wordbook_ids = params[:wordbook_ids]
  
    Wordbook.where(id: wordbook_ids).update_all(folder_id: target_folder.id)
  
    redirect_to folder_wordbooks_path(@folder), notice: "#{wordbook_ids.count}件の単語帳を移動しました"
  end

  # 単語帳のコピー先選択画面を表示
  # GET /wordbooks/copy_select
  def copy_select
    @folders = current_user.folders
    @wordbook_ids = params[:wordbook_ids]
  end
  
  # 選択された単語帳を別のフォルダにコピー
  # POST /wordbooks/copy_wordbooks
  def copy_wordbooks
    folder = current_user.folders.find(params[:target_folder_id])
    wordbooks = Wordbook.where(id: params[:wordbook_ids])
  
    # 単語帳とその中の単語をコピー
    wordbooks.each do |wordbook|
      new_book = folder.wordbooks.create!(
        title: wordbook.title,
        description: wordbook.description,
        is_public: false  # コピーした単語帳は非公開に設定
      )
  
      # 単語エントリーのコピー
      wordbook.word_entries.find_each do |entry|
        new_book.word_entries.create!(
          word: entry.word,
          meaning: entry.meaning,
          example_sentence: entry.example_sentence
        )
      end
    end
  
    redirect_to folder_wordbooks_path(folder), notice: "#{wordbooks.size}件の単語帳をコピーしました"
  end

  private

  # フォルダを取得し、アクセス権を確認
  # @raise [ActiveRecord::RecordNotFound] フォルダが存在しない場合
  def set_folder
    @folder = Folder.find(params[:folder_id])
  end

  # 許可されたパラメータを定義
  # @return [ActionController::Parameters] タイトル、説明、公開設定のみを許可
  def wordbook_params
    params.require(:wordbook).permit(:title, :description, :is_public)
  end
end
