class ShopsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :search]
  before_action :set_shop, only: [:update, :destroy]
  before_action :set_shop_breadcrumbs, only: [:search, :show, :edit]

  def show
    @shop = Shop.find(params[:id])
    @reviews = @shop.reviews
    @average_score = @reviews.average(:score)
    add_breadcrumb @shop.name
  end

  def new
    @shop = current_user.shops.build
    add_breadcrumb "お店を登録"
  end

  def create
    @shop = current_user.shops.build(shop_params)
    if @shop.save
      redirect_to root_path, notice: "新しい店舗を登録しました!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @shop = current_user.shops.find_by(id: params[:id])
    if @shop.nil?
      redirect_to root_path, notice: "このページにアクセスする権限がありません。"
    else
      add_breadcrumb @shop.name, shop_path(@shop)
      add_breadcrumb "店舗の編集"
    end
  end

  def update
    if @shop.update(shop_params)
      redirect_to @shop, notice: "店舗の情報を更新しました!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shop.destroy
    redirect_to root_path, notice: "店舗を削除しました!"
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
        @shops = @shops.left_joins(:likes).group(:id).order("COUNT(likes.id) DESC, shops.created_at DESC")
      end
    end

    @total_shops = @shops.count
    @shops = @shops.page(params[:page]).per(12)
  end

  private

  def shop_params
    params.require(:shop).permit(:name, :address, :price, :taste, :description, :product_name, :shop_url, :image)
  end

  def set_shop
    @shop = current_user.shops.find(params[:id])
  end

  def set_shop_breadcrumbs
    add_breadcrumb "検索結果", search_shops_path
  end
end
