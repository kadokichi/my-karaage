class User < ApplicationRecord
  has_one_attached :image
  has_many :shops, dependent: :destroy
  has_many :reviews
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
