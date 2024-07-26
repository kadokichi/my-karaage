class HomesController < ApplicationController
  NUMBER_OF_SHOP = 5
  def index
    @new_shops = Shop.includes(image_attachment: :blob).order(created_at: :desc).limit(NUMBER_OF_SHOP)
    @popular_shops = Shop.joins(:likes).includes(image_attachment: :blob).
      order(likes_count: :desc).limit(NUMBER_OF_SHOP).distinct
  end
end
