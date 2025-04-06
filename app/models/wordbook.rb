class Wordbook < ApplicationRecord
  belongs_to :folder
  has_many :word_entries, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
end
