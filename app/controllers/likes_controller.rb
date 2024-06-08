class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_shop

  def create
    @like = @shop.likes.new(user: current_user)
    if @like.save
      @shop.update_likes_count
      redirect_to @shop, notice: "いいねを追加しました!"
    end
  end

  def destroy
    @like = @shop.likes.find_by(user: current_user)
    if @like.destroy
      @shop.update_likes_count
      redirect_to @shop, notice: "いいねを取り消しました"
    end
  end

  private

  def find_shop
    @shop = Shop.find(params[:shop_id])
  end
end
