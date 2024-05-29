class Shop < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_many :likes, dependent: :destroy

  def shop_image
    if image.attached?
      image
    else
      "default-shop.jpg"
    end
  end

  def liked?(user)
    return false unless user
    likes.where(user_id: user.id).exists?
  end
end
