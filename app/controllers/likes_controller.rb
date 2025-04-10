class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wordbook

  def create
    current_user.likes.create!(wordbook: @wordbook)
    redirect_back fallback_location: root_path, notice: "いいねしました！"
  rescue ActiveRecord::RecordInvalid
    redirect_back fallback_location: root_path, alert: "いいねできませんでした"
  end

  def destroy
    current_user.likes.find_by!(wordbook_id: @wordbook.id).destroy!
    redirect_back fallback_location: root_path, notice: "いいねを取り消しました"
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, alert: "いいねが見つかりませんでした"
  end

  private

  def set_wordbook
    @wordbook = Wordbook.find(params[:wordbook_id])
  end
end