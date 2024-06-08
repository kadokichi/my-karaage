class HomesController < ApplicationController
  def index
    @new_shops = Shop.includes(image_attachment: :blob).order(created_at: :desc).limit(5)
    @popular_shops = Shop.joins(:likes).includes(image_attachment: :blob).order(created_at: :desc).limit(5)
  end
end
