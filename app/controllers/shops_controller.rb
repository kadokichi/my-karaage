class ShopsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    @shops = Shop.all
  end

  def show
    @shop = Shop.find(params[:id])
    @reviews = @shop.reviews
    @average_score = @reviews.average(:score)
  end

  def new
    @shop = current_user.shops.build
  end
    
  def create
    @shop = current_user.shops.build(shop_params)
    if @shop.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @shop = current_user.shops.find(params[:id])
  end

  def update
    @shop = current_user.shops.find(params[:id])
    if @shop.update(shop_params)
      redirect_to @shop
    else
      render :edit
    end
  end
    
  def destroy
    @shop = current_user.shops.find(params[:id])
    @shop.destroy
    redirect_to root_path
  end
    
  private
    
  def shop_params
    params.require(:shop).permit(:name, :address, :price, :taste, :description, :product_name, :shop_url, :image)
  end
end
