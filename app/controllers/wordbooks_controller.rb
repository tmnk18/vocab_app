class WordbooksController < ApplicationController
  before_action :authenticate_user!, except: [:public_index]
  before_action :set_folder, except: [:public_index, :copy_select, :copy_wordbooks]

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

  def move
    @wordbooks = @folder.wordbooks
    @other_folders = current_user.folders.where.not(id: @folder.id)
  end

  def move_wordbooks
    @folder = Folder.find(params[:folder_id])  # 移動元フォルダ
    target_folder = Folder.find(params[:target_folder_id])  # 移動先フォルダ
    wordbook_ids = params[:wordbook_ids]
  
    Wordbook.where(id: wordbook_ids).update_all(folder_id: target_folder.id)
  
    redirect_to folder_wordbooks_path(@folder), notice: "#{wordbook_ids.count}件の単語帳を移動しました"
  end

  def copy_select
    @folders = current_user.folders
    @wordbook_ids = params[:wordbook_ids]
  end
  
  def copy_wordbooks
    folder = current_user.folders.find(params[:target_folder_id])
    wordbooks = Wordbook.where(id: params[:wordbook_ids])
  
    wordbooks.each do |wordbook|
      new_book = folder.wordbooks.create!(
        title: wordbook.title,
        description: wordbook.description,
        is_public: false # コピーは非公開にしておくなど
      )
  
      wordbook.word_entries.find_each do |entry|
        new_book.word_entries.create!(word: entry.word, meaning: entry.meaning, example_sentence: entry.example_sentence)
      end
    end
  
    redirect_to folder_wordbooks_path(folder), notice: "#{wordbooks.size}件の単語帳をコピーしました"
  end



  private

  def set_folder
    @folder = Folder.find(params[:folder_id])
  end

  def wordbook_params
    params.require(:wordbook).permit(:title, :description, :is_public)
  end
end
