class User < ApplicationRecord
  has_many :folders, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_wordbooks, through: :likes, source: :wordbook
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  validate :avatar_format

  private

  def avatar_format
    return unless avatar.attached?
    unless avatar.content_type.in?(%w[image/png image/jpg image/jpeg])
      errors.add(:avatar, "はPNG、JPG、JPEG形式の画像のみアップロードできます")
    end
  end
end