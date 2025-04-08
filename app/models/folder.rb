class Folder < ApplicationRecord
  belongs_to :user
  has_many :wordbooks, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id, message: "フォルダ名が重複しています" }, length: { maximum: 50 }
end
