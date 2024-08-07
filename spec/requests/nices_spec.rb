require 'rails_helper'

RSpec.describe "Nices", type: :request do
  let!(:user) { create(:user) }
  let!(:shop) { create(:shop, user: user) }
  let!(:review) { create(:review, user: user, shop: shop) }

  describe "POST /nices" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        get shop_reviews_path(shop)
      end

      it "レビューにいいねでき、カウントが反映されること" do
        post shop_review_nice_path(shop_id: shop.id, review_id: review.id)
        expect(response).to redirect_to(shop_reviews_path(review.shop))
        follow_redirect!
        expect(response.body).to include("いいねを追加しました!")
        review.reload
        expect(review.nices_count).to eq(1)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get shop_reviews_path(shop)
      end

      it "レビューにいいねができず、ログインページに遷移すること" do
        post shop_review_nice_path(shop_id: shop.id, review_id: review.id)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /nices" do
    let!(:nice) { create(:nice, review: review, user: user) }

    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        get shop_reviews_path(shop)
      end

      it "いいねを削除し、カウントが反映されること" do
        delete shop_review_nice_path(shop_id: shop.id, review_id: review.id)
        expect(response).to redirect_to(shop_reviews_path(review.shop))
        follow_redirect!
        expect(response.body).to include("いいねを取り消しました")
        review.reload
        expect(review.nices_count).to eq(0)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get shop_reviews_path(shop)
      end

      it "いいねを削除できず、ログインページに遷移すること" do
        delete shop_review_nice_path(shop_id: shop.id, review_id: review.id)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
