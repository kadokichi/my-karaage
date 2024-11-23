class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_shop
  before_action :set_review, only: [:edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]
  before_action :set_review_breadcrumbs, only: [:index, :new, :edit]

  def index
    if user_signed_in?
      @reviews = @shop.reviews.includes(:user, :nices).order(created_at: :desc)
    else
      @reviews = @shop.reviews.includes(:user)
    end
  end

  def new
    @review = @shop.reviews.build
    add_breadcrumb "レビューを書く"
  end

  def create
    @review = @shop.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to shop_path(@shop), notice: "レビューを投稿しました!"
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "レビューの編集"
  end

  def update
    if @review.update(review_params)
      redirect_to shop_path(@review.shop), notice: "レビューを更新しました!"
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to shop_path(@review.shop), notice: "レビューを削除しました!"
  end

  private

  def review_params
    params.require(:review).permit(:content, :score)
  end

  def set_shop
    @shop = Shop.find(params[:shop_id])
  end

  def set_review
    @review = @shop.reviews.find(params[:id])
  end

  def set_review_breadcrumbs
    add_breadcrumb "検索結果", search_shops_path
    add_breadcrumb @shop.name, shop_path(@shop)
    add_breadcrumb "#{@shop.name} のレビュー", shop_reviews_path(@shop)
  end

  def authorize_user!
    redirect_to root_path, notice: "権限がありません。" unless @review.user == current_user
  end
end
