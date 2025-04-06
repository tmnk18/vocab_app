class WordbooksController < ApplicationController
  before_action :authenticate_user!, except: [:public_index]
  before_action :set_folder, except: [:public_index]

  def index
    session.delete(:from_public_list) 
    @wordbooks = @folder.wordbooks
  end

  def public_index
    @wordbooks = Wordbook.includes(:folder).where(is_public: true).order(created_at: :desc)
  end

  def new
    @wordbook = @folder.wordbooks.build
  end

  def create
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.build(wordbook_params)
  
    if @wordbook.save
      redirect_to folder_wordbooks_path(@folder), notice: "単語帳を作成しました"
    else
      flash.now[:alert] = "単語帳の作成に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.find(params[:id])
  end
  
  def update
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.find(params[:id])
    if @wordbook.update(wordbook_params)
      redirect_to folder_wordbooks_path(@folder), notice: "単語帳を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.find(params[:id])
    @wordbook.destroy
    redirect_to folder_wordbooks_path(@folder), notice: "単語帳を削除しました"
  end

  private

  def set_folder
    @folder = Folder.find(params[:folder_id])
  end

  def wordbook_params
    params.require(:wordbook).permit(:title, :description, :is_public)
  end
end