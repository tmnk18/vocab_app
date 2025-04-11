require 'net/http'
require 'uri'
require 'json'

class DictionaryService
  BASE_URL = "https://api.dictionaryapi.dev/api/v2/entries/en"

  def self.lookup(word)
    return { error: "Word cannot be blank" } if word.blank?

    url = URI("#{BASE_URL}/#{URI.encode_www_form_component(word)}")
    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      meanings = data.first["meanings"].map do |meaning|
        {
          part_of_speech: meaning["partOfSpeech"],
          definitions: meaning["definitions"].map { |d| d["definition"] }
        }
      end
      { word: word, meanings: meanings }
    else
      { error: "意味を取得できませんでした" }
    end
  rescue => e
    { error: "意味を取得できませんでした" }
  end

  def self.fetch_meaning(word)
    result = lookup(word)
    if result[:meanings]
      # 最初の意味を取得
      meaning = result[:meanings][0][:definitions][0]

      # 200文字以内に収める処理
      if meaning.length > 200
        truncated = meaning[0...200]
        last_period_index = truncated.rindex('.')
        if last_period_index
          truncated = truncated[0..last_period_index] + " etc."
        else
          truncated += " etc."
        end
        truncated
      else
        meaning
      end
    else
      result[:error] || "意味が見つかりませんでした"
    end
  end
end