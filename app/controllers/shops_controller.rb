class ShopsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index, :search]

  def index
    @shops = Shop.includes(image_attachment: :blob).all
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
      render :new, status: :unprocessable_entity
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
      render :edit, status: :unprocessable_entity
    end
  end
    
  def destroy
    @shop = current_user.shops.find(params[:id])
    @shop.destroy
    redirect_to root_path
  end

  def search
    @shops = Shop.includes(image_attachment: :blob).all

    if params[:address].present?
      @shops = @shops.where("address LIKE ? ", "%#{params[:address]}%")
    end

    if params[:word].present?
      @shops = @shops.where("name LIKE ? ", "%#{params[:word]}%")
    end
    
    if params[:taste].present?
      @shops = @shops.where(taste: params[:taste])
    end

    if params[:sort].present?
      case params[:sort]
      when "latest"
        @shops = @shops.order(id: :desc)
      when "oldest"
        @shops = @shops.order(id: :asc)
      when "popular"
        @shops = @shops.left_joins(:likes).group(:id).order('COUNT(likes.id) DESC')
      end
    end
    
    render :index
  end
    
  private
    
  def shop_params
    params.require(:shop).permit(:name, :address, :price, :taste, :description, :product_name, :shop_url, :image)
  end
end
