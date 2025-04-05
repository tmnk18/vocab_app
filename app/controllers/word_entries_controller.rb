class WordEntriesController < ApplicationController
  before_action :set_folder_and_wordbook

  def index
    @word_entries = @wordbook.word_entries
  end

  def show
    @word_entry = @wordbook.word_entries.find(params[:id])
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

  private

  def set_folder_and_wordbook
    @folder = Folder.find(params[:folder_id])
    @wordbook = @folder.wordbooks.find(params[:wordbook_id])
  end

  def word_entry_params
    params.require(:word_entry).permit(:word, :meaning, :example_sentence)
  end
end