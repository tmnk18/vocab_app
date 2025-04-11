# 単語エントリー管理用コントローラー
# 単語帳に属する単語の作成、編集、削除、移動などの機能を担当
class WordEntriesController < ApplicationController
  # 未ログインユーザーでも公開単語帳の閲覧は可能
  before_action :authenticate_user!, unless: -> {
    action_name.in?(%w[show index]) && Wordbook.find(params[:wordbook_id]).is_public?
  }
  before_action :set_folder_and_wordbook, except: [:show, :index]
  before_action :set_folder_and_wordbook_for_public_access, only: [:show, :index]
  before_action :set_word_entry, only: [:show, :edit, :update]

  # 単語一覧を表示
  # GET /folders/:folder_id/wordbooks/:wordbook_id/word_entries
  def index
    @word_entries = @wordbook.word_entries
  
    # 公開一覧から来たらフラグをセット（1回だけ）
    if request.referer&.include?(public_index_wordbooks_path)
      session[:from_public_list] = true
    end
  
    @from_public_list = session[:from_public_list]
  end

  # 単語の詳細を表示
  # GET /folders/:folder_id/wordbooks/:wordbook_id/word_entries/:id
  def show
    # @folder, @wordbook は before_action でセット済み
  end

  # 単語作成フォームを表示
  # GET /folders/:folder_id/wordbooks/:wordbook_id/word_entries/new
  def new
    @word_entry = @wordbook.word_entries.new
  end

  # 単語を作成
  # POST /folders/:folder_id/wordbooks/:wordbook_id/word_entries
  def create
    @word_entry = @wordbook.word_entries.new(word_entry_params)
    if @word_entry.save
      redirect_to folder_wordbook_word_entries_path(@folder, @wordbook), notice: "単語を追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 単語編集フォームを表示
  # GET /folders/:folder_id/wordbooks/:wordbook_id/word_entries/:id/edit
  def edit; end

  # 単語を更新
  # PATCH/PUT /folders/:folder_id/wordbooks/:wordbook_id/word_entries/:id
  def update
    if @word_entry.update(word_entry_params)
      redirect_to folder_wordbook_word_entry_path(@folder, @wordbook, @word_entry), notice: "単語を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 単語の移動画面を表示
  # GET /folders/:folder_id/wordbooks/:wordbook_id/word_entries/move
  def move
    # 選択された単語と移動先候補の単語帳を取得
    @word_entries = @wordbook.word_entries.where(id: params[:entry_ids])
    @other_wordbooks = @folder.wordbooks.where.not(id: @wordbook.id)
  end

  # 選択された単語を別の単語帳に移動
  # PATCH /folders/:folder_id/wordbooks/:wordbook_id/word_entries/move_entries
  def move_entries
    target_wordbook = Wordbook.find(params[:target_wordbook_id])
    entry_ids = params[:entry_ids]
    WordEntry.where(id: entry_ids).update_all(wordbook_id: target_wordbook.id)

    redirect_to folder_wordbook_word_entries_path(@folder, @wordbook),
                notice: "#{entry_ids.count}件の単語を移動しました"
  end

  # 選択された単語を一括削除（Ajax対応）
  # DELETE /folders/:folder_id/wordbooks/:wordbook_id/word_entries/delete_entries
  def delete_entries
    entry_ids = params[:entry_ids]

    if entry_ids.present?
      WordEntry.where(id: entry_ids).destroy_all
      render json: {
        redirect_url: folder_wordbook_word_entries_path(@folder, @wordbook),
        notice: "#{entry_ids.count}件の単語を削除しました"
      }
    else
      render json: { error: "削除する単語を選択してください" }, status: :unprocessable_entity
    end
  end

  private

  # フォルダと単語帳を取得（通常のアクセス用）
  # @raise [ActiveRecord::RecordNotFound] フォルダまたは単語帳が存在しない場合
  def set_folder_and_wordbook
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.find(params[:wordbook_id])
  end

  # フォルダと単語帳を取得（公開アクセス用）
  # 非公開の単語帳へのアクセスをブロック
  def set_folder_and_wordbook_for_public_access
    @wordbook = Wordbook.find(params[:wordbook_id])
    if !@wordbook.is_public? && !user_signed_in?
      redirect_to root_path, alert: "この単語帳は非公開です"
    end
    @folder = @wordbook.folder if user_signed_in?
  end

  # 単語エントリーを取得
  # @raise [ActiveRecord::RecordNotFound] 単語が存在しない場合
  def set_word_entry
    @word_entry = WordEntry.find(params[:id])
  end

  # 許可されたパラメータを定義
  # @return [ActionController::Parameters] 単語、意味、例文のみを許可
  def word_entry_params
    params.require(:word_entry).permit(:word, :meaning, :example_sentence)
  end
end