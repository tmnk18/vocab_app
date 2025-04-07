class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: [:edit, :update, :destroy]

  def index
    session.delete(:from_public_list)
    @folders = current_user.folders.order(created_at: :desc)
  end

  def new
    @folder = current_user.folders.new
  end

  def create
    @folder = current_user.folders.new(folder_params)
    if @folder.save
      redirect_to folders_path, notice: "フォルダを作成しました"
    else
      flash.now[:alert] = "フォルダの作成に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @folder.update(folder_params)
      redirect_to folders_path, notice: "フォルダを更新しました"
    else
      flash.now[:alert] = "フォルダの更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @folder.destroy
    redirect_to folders_path, notice: "フォルダを削除しました"
  end

  def wordbooks
    folder = current_user.folders.find(params[:id])
    render json: folder.wordbooks.select(:id, :title)
  end

  private

  def set_folder
    @folder = current_user.folders.find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:name)
  end
end