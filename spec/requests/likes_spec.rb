require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let!(:user) { create(:user) }
  let!(:shop) { create(:shop, user: user) }

  describe "POST /likes" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        get shop_path(shop)
      end

      it "店舗にいいねでき、カウントが反映されること" do
        post shop_like_path(shop_id: shop.id)
        expect(response).to redirect_to(shop_path(shop))
        follow_redirect!
        expect(response.body).to include("いいねを追加しました!")
        shop.reload
        expect(shop.likes_count).to eq(1)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get shop_path(shop)
      end

      it "レビューにいいねができず、ログインページに遷移すること" do
        post shop_like_path(shop_id: shop.id)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /likes" do
    let!(:like) { create(:like, shop: shop, user: user) }

    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        get shop_path(shop)
      end

      it "いいねを削除し、カウントが反映されること" do
        delete shop_like_path(shop_id: shop.id)
        expect(response).to redirect_to(shop_path(shop))
        follow_redirect!
        expect(response.body).to include("いいねを取り消しました")
        shop.reload
        expect(shop.likes_count).to eq(0)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get shop_path(shop)
      end

      it "いいねを削除できず、ログインページに遷移すること" do
        delete shop_like_path(shop_id: shop.id)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
