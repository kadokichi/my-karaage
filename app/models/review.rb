class Review < ApplicationRecord
  belongs_to :shop
  belongs_to :user
  has_many :nices, dependent: :destroy

  validates :user_id, uniqueness: { scope: :shop_id }

  def niced_by?(user)
    return false unless user
    nices.any? { |nice| nice.user_id == user.id }
  end

  def update_nices_count
    update_column(:nices_count, nices.count)
  end
end
