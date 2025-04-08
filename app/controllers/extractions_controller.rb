class ExtractionsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def tokenize
    @original_sentence = params[:sentence]
    @tokens = @original_sentence.split(/\s+/).uniq
  end

  def fetch_meanings
    return redirect_to new_extraction_path if request.get?
  
    selected_words = params[:words] || []
  
    @entries = selected_words.map do |word|
      {
        word: word,
        meaning: fetch_meaning(word)
      }
    end
  
    render :confirm
  end

  def select_target
    entries_param = params[:entries]
  
    if entries_param.blank?
      redirect_to new_extraction_path
      return
    end
  
    @entries = entries_param
    @folders = current_user.folders
    @words = @entries.map { |entry| entry[:word] }
    @meanings = @entries.map { |entry| entry[:meaning] }
  end

  def register
    folder_id = params[:folder_id]
    wordbook_id = params[:wordbook_id]
    entries = params[:entries] || []
  
    wordbook = current_user.folders.find(folder_id).wordbooks.find(wordbook_id)
  
    entries.each do |entry|
      wordbook.word_entries.create!(
        word: entry[:word],
        meaning: entry[:meaning]
      )
    end
  
    redirect_to folder_wordbook_word_entries_path(wordbook.folder, wordbook), notice: "#{entries.size}件の単語を追加しました。"
  end

  private

  def fetch_meaning(word)
    DictionaryService.fetch_meaning(word)
  end
end