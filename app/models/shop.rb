class Shop < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_many :likes, dependent: :destroy
  geocoded_by :address
  after_validation :geocode

  validates :name, presence: true, length: { maximum: 30 }, uniqueness: { case_sensitive: false }
  validates :address, presence: true, length: { maximum: 50 }
  validates :price, presence: true, numericality: { only_integer: true }, length: { minimum: 2, maximum: 5 }
  validates :taste, presence: true
  validates :description, presence: true, length: { maximum: 150 }
  validates :product_name, presence: true, length: { maximum: 20 }

  def shop_image
    if image.attached?
      image
    else
      "default-shop.jpg"
    end
  end

  def update_likes_count
    update_column(:likes_count, likes.count)
  end

  def liked?(user)
    return false unless user
    likes.exists?(user_id: user.id)
  end
end
