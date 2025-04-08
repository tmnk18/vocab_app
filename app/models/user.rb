class User < ApplicationRecord
  has_many :folders, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_wordbooks, through: :likes, source: :wordbook
  
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  # バリデーション
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :username, presence: true, length: { maximum: 50 }

  validate :avatar_format

  # パスワードなしで更新するメソッド
  def update_without_password(params, *options)
    params.delete(:password)
    params.delete(:password_confirmation)
    params.delete(:current_password)

    update(params, *options)
  end

  private

  def avatar_format
    return unless avatar.attached?
    unless avatar.content_type.in?(%w[image/png image/jpg image/jpeg])
      errors.add(:avatar, "はPNG、JPG、JPEG形式の画像のみアップロードできます")
    end
  end
end