class ExtractionsController < ApplicationController
  before_action :authenticate_user!

  def new
    # 英文入力画面（ステップ1）
  end

  def tokenize
    @original_sentence = params[:sentence]
    @tokens = @original_sentence.split(/\s+/).uniq
  end

  def fetch_meanings
    # 選択した単語の意味を取得（ステップ3）
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
    @folders = current_user.folders
    @entries = params[:entries]
    @words = params[:entries].map { |entry| entry[:word] }
    @meanings = params[:entries].map { |entry| entry[:meaning] }
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
    # 将来的に辞書API連携予定。今は仮で "テスト"
    "テスト"
  end
end