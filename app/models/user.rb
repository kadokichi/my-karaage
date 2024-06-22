class User < ApplicationRecord
  has_one_attached :image
  has_many :shops, dependent: :destroy
  has_many :reviews
  has_many :likes, dependent: :destroy
  has_many :liked_shops, through: :likes, source: :shop
  has_many :nices, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { case_sensitive: false }
  validates :email, presence: true, length: { maximum: 50 },
    format: { with: Devise.email_regexp },
    uniqueness: { case_sensitive: false }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def user_image
    if image.attached?
      image
    else
      "default-user.jpg"
    end
  end
end
