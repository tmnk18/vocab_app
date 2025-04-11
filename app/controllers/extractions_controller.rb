# 英文からの単語抽出機能を管理するコントローラー
# 単語の抽出、意味の取得、単語帳への登録までの一連の流れを処理
class ExtractionsController < ApplicationController
  before_action :authenticate_user! # ログインユーザーのみアクセス可能

  MAX_WORDS = 10 # 選択できる単語の最大数

  # 英文入力フォームを表示
  # GET /extractions/new
  def new
  end

  # 入力された英文を単語に分割
  # POST /extractions/tokenize
  def tokenize
    @original_sentence = params[:sentence]
    @tokens = @original_sentence.split(/\s+/).uniq  # 重複を除去して単語を抽出
  end

  # 選択された単語の意味を取得
  # POST /extractions/fetch_meanings
  def fetch_meanings
    # GETリクエストの場合は入力フォームにリダイレクト
    return redirect_to new_extraction_path if request.get?

    selected_words = params[:words] || []

    # 単語数のバリデーション
    if selected_words.size > MAX_WORDS
      redirect_to new_extraction_path, alert: "選択できる単語は最大#{MAX_WORDS}個までです。"
      return
    end

    # 各単語について辞書APIから意味を取得
    @entries = selected_words.map do |word|
      {
        word: word,
        meaning: fetch_meaning(word)
      }
    end

    render :confirm # 確認画面を表示
  end

  # 単語の登録先選択画面を表示
  # POST /extractions/select_target
  def select_target
    entries_param = params[:entries]
  
    # 単語が選択されていない場合は入力フォームにリダイレクト
    if entries_param.blank?
      redirect_to new_extraction_path
      return
    end
  
    # 登録用のデータを準備
    @entries = entries_param
    @folders = current_user.folders
    @words = @entries.map { |entry| entry[:word] }
    @meanings = @entries.map { |entry| entry[:meaning] }
  end

  # 単語を指定された単語帳に登録
  # POST /extractions/register
  def register
    folder_id = params[:folder_id]
    wordbook_id = params[:wordbook_id]
    entries = params[:entries] || []
  
    # 指定された単語帳を取得（権限チェックを含む）
    wordbook = current_user.folders.find(folder_id).wordbooks.find(wordbook_id)
  
    # 各単語をデータベースに登録
    entries.each do |entry|
      wordbook.word_entries.create!(
        word: entry[:word],
        meaning: entry[:meaning]
      )
    end
  
    # 登録完了後、単語一覧ページにリダイレクト
    redirect_to folder_wordbook_word_entries_path(wordbook.folder, wordbook), 
                notice: "#{entries.size}件の単語を追加しました。"
  end

  private

  # 単語の意味を外部APIから取得
  # @param [String] word 検索する単語
  # @return [String] 取得した意味
  def fetch_meaning(word)
    DictionaryService.fetch_meaning(word)
  end
end