class WordEntry < ApplicationRecord
  belongs_to :wordbook

  validates :word, presence: true
  validates :meaning, presence: true
end