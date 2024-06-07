class HomesController < ApplicationController
  def index
    @new_shops = Shop.order(created_at: :desc).limit(5)
    @popular_shops = Shop.joins(:likes).group("shops.id").order("COUNT(likes.id) DESC").limit(5)
  end
end
