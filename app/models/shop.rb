class Shop < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  has_many :reviews, dependent: :destroy

  def shop_image
    if image.attached?
      image
    else
      "default-shop.jpg"
    end
  end
end
