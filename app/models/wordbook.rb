class Wordbook < ApplicationRecord
  belongs_to :folder
  has_many :word_entries, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  # バリデーション
  validates :title, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 200 }, allow_blank: true
  validates :folder_id, presence: true
end
