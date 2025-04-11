# いいね機能を管理するコントローラー
# 単語帳へのいいねの作成と削除を担当
class LikesController < ApplicationController
  before_action :authenticate_user! # ログインユーザーのみアクセス可能
  before_action :set_wordbook      # 対象の単語帳を取得

  # いいねを作成
  # POST /wordbooks/:wordbook_id/likes
  def create
    # 現在のユーザーが対象の単語帳にいいねを作成
    current_user.likes.create!(wordbook: @wordbook)
    redirect_back fallback_location: root_path, notice: "いいねしました！"
  rescue ActiveRecord::RecordInvalid
    # すでにいいね済みなど、作成に失敗した場合
    redirect_back fallback_location: root_path, alert: "いいねできませんでした"
  end

  # いいねを削除
  # DELETE /wordbooks/:wordbook_id/likes
  def destroy
    # 現在のユーザーの対象単語帳へのいいねを削除
    current_user.likes.find_by!(wordbook_id: @wordbook.id).destroy!
    redirect_back fallback_location: root_path, notice: "いいねを取り消しました"
  rescue ActiveRecord::RecordNotFound
    # いいねが存在しない場合
    redirect_back fallback_location: root_path, alert: "いいねが見つかりませんでした"
  end

  private

  # いいね対象の単語帳を取得
  # @raise [ActiveRecord::RecordNotFound] 単語帳が存在しない場合
  def set_wordbook
    @wordbook = Wordbook.find(params[:wordbook_id])
  end
end