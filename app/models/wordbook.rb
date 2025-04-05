class Wordbook < ApplicationRecord
  belongs_to :folder
  has_many :word_entries, dependent: :destroy
end
