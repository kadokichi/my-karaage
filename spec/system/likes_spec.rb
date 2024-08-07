require 'rails_helper'

RSpec.describe "Likes", type: :system do
  let!(:user) { create(:user) }
  let!(:shop) { create(:shop, user: user) }

  describe "いいねを追加" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        visit shop_path(shop)
      end

      it "レビューにいいねでき、カウントが反映されること" do
        within ".store-rating" do
          click_on shop.likes_count.to_s
        end

        expect(current_path).to eq(shop_path(shop))
        expect(page).to have_content("いいねを追加しました!")
        expect(page).to have_selector("i.fas.fa-heart.unlike-btn")
        expect(page).to have_content(shop.likes_count + 1)
        shop.reload
        expect(shop.likes_count).to eq(1)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        visit shop_path(shop)
      end

      it "レビューにいいねができず、ログインページに遷移すること" do
        within ".store-rating" do
          click_on shop.likes_count.to_s
        end

        expect(current_path).to eq(new_user_session_path)
      end
    end
  end

  describe "いいねを削除" do
    let!(:like) { create(:like, shop: shop, user: user) }

    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        visit shop_path(shop)
        shop.reload
      end

      it "レビューのいいねを削除でき、カウントが反映されること" do
        within ".store-rating" do
          click_on shop.likes_count.to_s
        end

        expect(current_path).to eq(shop_path(shop))
        expect(page).to have_content("いいねを取り消しました")
        expect(page).to have_selector("i.far.fa-heart.like-btn")
        expect(page).to have_content(shop.likes_count - 1)
        shop.reload
        expect(shop.likes_count).to eq(0)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        visit shop_path(shop)
        shop.reload
      end

      it "レビューを削除できず、ログインページに遷移すること" do
        within ".store-rating" do
          click_on shop.likes_count.to_s
        end

        expect(current_path).to eq(new_user_session_path)
      end
    end
  end
end
