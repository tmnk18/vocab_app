class Folder < ApplicationRecord
  belongs_to :user
  has_many :wordbooks, dependent: :destroy
end
