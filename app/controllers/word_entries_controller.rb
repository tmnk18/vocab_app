class WordEntriesController < ApplicationController
  before_action :set_folder_and_wordbook
  before_action :set_word_entry, only: [:show, :edit, :update]

  def index
    @word_entries = @wordbook.word_entries
  end

  def show
  end

  def new
    @word_entry = @wordbook.word_entries.new
  end

  def create
    @word_entry = @wordbook.word_entries.new(word_entry_params)
    if @word_entry.save
      redirect_to folder_wordbook_word_entries_path(@folder, @wordbook), notice: "単語を追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @word_entry.update(word_entry_params)
      redirect_to folder_wordbook_word_entry_path(@folder, @wordbook, @word_entry), notice: "単語を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def move
    @word_entries = @wordbook.word_entries.where(id: params[:entry_ids])
    @other_wordbooks = @folder.wordbooks.where.not(id: @wordbook.id)
  end

  def move_entries
    target_wordbook = Wordbook.find(params[:target_wordbook_id])
    entry_ids = params[:entry_ids]

    WordEntry.where(id: entry_ids).update_all(wordbook_id: target_wordbook.id)

    redirect_to folder_wordbook_word_entries_path(@folder, @wordbook),
                notice: "#{entry_ids.count}件の単語を移動しました"
  end

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

  def set_folder_and_wordbook
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.find(params[:wordbook_id])
  end

  def set_word_entry
    @word_entry = @wordbook.word_entries.find(params[:id])
  end

  def word_entry_params
    params.require(:word_entry).permit(:word, :meaning, :example_sentence)
  end
end