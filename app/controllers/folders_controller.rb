# フォルダ管理用コントローラー
# ユーザーごとのフォルダの作成、編集、削除、および単語帳の一覧取得を担当
class FoldersController < ApplicationController
  before_action :authenticate_user! # ログインユーザーのみアクセス可能
  before_action :set_folder, only: [:edit, :update, :destroy] # 編集・更新・削除時のフォルダ取得と権限チェック

  # フォルダ一覧を表示
  # GET /folders
  def index
    session.delete(:from_public_list) # 公開リストからの遷移フラグをクリア
    @folders = current_user.folders.order(created_at: :desc) # 作成日時の降順で取得
  end

  # フォルダ作成フォームを表示
  # GET /folders/new
  def new
    @folder = current_user.folders.new
  end

  # フォルダを作成
  # POST /folders
  def create
    @folder = current_user.folders.new(folder_params)
    if @folder.save
      redirect_to folders_path, notice: "フォルダを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # フォルダ編集フォームを表示
  # GET /folders/:id/edit
  def edit
  end

  # フォルダを更新
  # PATCH/PUT /folders/:id
  def update
    if @folder.update(folder_params)
      redirect_to folders_path, notice: "フォルダを更新しました"
    else
      flash.now[:alert] = "フォルダの更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  # フォルダを削除
  # DELETE /folders/:id
  def destroy
    # フォルダの存在確認と取得
    folder = Folder.find(params[:id])

    # 権限チェック - 自分のフォルダのみ削除可能
    unless folder.user_id == current_user.id
      render status: :forbidden, json: { error: '権限がありません' }
      return
    end

    # 削除処理と完了通知
    folder.destroy
    redirect_to folders_path, notice: "フォルダを削除しました"
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: { error: 'フォルダが見つかりません' }
  end

  # 指定されたフォルダの単語帳一覧をJSONで返す（非推奨）
  # GET /folders/:id/wordbooks
  def wordbooks
    folder = current_user.folders.find(params[:id])
    render json: folder.wordbooks.select(:id, :title)
  end

  # フォルダに属する単語帳をJSONで返す
  # GET /folders/:id/wordbooks_list
  def wordbooks_list
    folder = current_user.folders.find(params[:id])
    wordbooks = folder.wordbooks.select(:id, :title)
    render json: wordbooks
  end

  private

  # 編集・更新・削除対象のフォルダを取得し、権限をチェック
  # @raise [ActiveRecord::RecordNotFound] フォルダが存在しない場合
  def set_folder
    folder = Folder.find(params[:id])
    
    # 自分のフォルダ以外へのアクセスを禁止
    unless folder.user_id == current_user.id
      render status: :forbidden, json: { error: '権限がありません' }
      return
    end

    @folder = folder
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: { error: 'フォルダが見つかりません' }
  end

  # 許可されたパラメータを定義
  # @return [ActionController::Parameters] フォルダ名のみを許可
  def folder_params
    params.require(:folder).permit(:name)
  end
end