class DictionaryService
  def self.lookup(word)
    # 今はどんな単語でも"テスト"を返す
    {
      word: word,
      meaning: "テスト"
			# meaning: ExternalDictionaryAPI.lookup(word)
    }
  end
end