class Like < ApplicationRecord
  belongs_to :user
  belongs_to :shop
  counter_culture :shop, column_name: "likes_count", touch: true

  validates :user, presence: true
  validates :shop, presence: true
end
