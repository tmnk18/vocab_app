class WordEntry < ApplicationRecord
  belongs_to :wordbook

  validates :word, presence: true, length: { maximum: 50 }
  validates :meaning, length: { maximum: 200 }, allow_blank: true
  validates :example_sentence, length: { maximum: 300 }, allow_blank: true
end