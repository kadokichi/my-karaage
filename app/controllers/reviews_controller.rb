class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_review_breadcrumbs, only: [:index, :new, :edit]

  def index
    @shop = Shop.find(params[:shop_id])
    if user_signed_in?
      @reviews = @shop.reviews.includes(:user, :nices)
    else
      @reviews = @shop.reviews.includes(:user)
    end
  end

  def new
    @shop = Shop.find(params[:shop_id])
    @review = @shop.reviews.build
    add_breadcrumb "レビューを書く"
  end
  
  def create
    @shop = Shop.find(params[:shop_id])
    @review = @shop.reviews.build(review_params)
    @review.user = current_user
    
    if @review.save
      redirect_to shop_path(@shop), notice: "レビューを投稿しました!"
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit
    @shop = Shop.find(params[:shop_id])
    @review = Review.find(params[:id])
    add_breadcrumb "レビューの編集"
  end

  def update
    @shop = Shop.find(params[:shop_id])
    @review = Review.find(params[:id])
    if @review.update(review_params)
      redirect_to shop_path(@review.shop), notice: "レビューを更新しました!"
    else
      render "edit", status: :unprocessable_entity
    end
  end
  
  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to shop_path(@review.shop), notice: "レビューを削除しました!"
  end
    
  private
    
  def review_params
    params.require(:review).permit(:content, :score)
  end

  def set_review_breadcrumbs
    add_breadcrumb "検索結果", search_shops_path
    @shop = Shop.find(params[:shop_id])
    add_breadcrumb @shop.name, shop_path(@shop)
    add_breadcrumb "#{@shop.name} のレビュー", shop_reviews_path(@shop)
  end
end
