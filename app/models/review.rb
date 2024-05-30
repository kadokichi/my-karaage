class Review < ApplicationRecord
  belongs_to :shop
  belongs_to :user
  has_many :nices, dependent: :destroy

  validates :user_id, uniqueness: { scope: :shop_id }

  def niced?(user)
    return false unless user
    nices.exists?(user_id: user.id)
  end
end
