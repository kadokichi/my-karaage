class NicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review

  def create
    @nice = @review.nices.build(user: current_user)
    if @nice.save
      @review.update_nices_count
      redirect_to shop_review_path(@review.shop, @review), notice: "いいねを追加しました!"
    end
  end

  def destroy
    @nice = @review.nices.find_by(user: current_user)
    if @nice.destroy
      @review.update_nices_count
      redirect_to shop_review_path(@review.shop, @review), notice: "いいねを取り消しました"
    end
  end

  private

  def set_review
    @review = Review.find(params[:review_id])
  end
end
