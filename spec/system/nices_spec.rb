require 'rails_helper'

RSpec.describe "Nices", type: :system do
  let!(:user) { create(:user) }
  let!(:shop) { create(:shop, user: user) }
  let!(:review) { create(:review, user: user, shop: shop) }

  describe "いいねを追加" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        visit shop_reviews_path(shop)
      end

      it "レビューにいいねでき、カウントが反映されること" do
        within ".reviews-nice" do
          click_on review.nices_count.to_s
        end

        expect(current_path).to eq(shop_reviews_path(review.shop))
        expect(page).to have_content("いいねを追加しました!")
        expect(page).to have_selector("i.fas.fa-heart.small-unlike-btn")
        expect(page).to have_content(review.nices_count + 1)
        review.reload
        expect(review.nices_count).to eq(1)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        visit shop_reviews_path(shop)
      end

      it "レビューにいいねができず、ログインページに遷移すること" do
        within ".reviews-nice" do
          click_on review.nices_count.to_s
        end

        expect(current_path).to eq(new_user_session_path)
      end
    end
  end

  describe "いいねを削除" do
    let!(:nice) { create(:nice, review: review, user: user) }

    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        visit shop_reviews_path(shop)
        review.reload
      end

      it "レビューのいいねを削除でき、カウントが反映されること" do
        within ".reviews-nice" do
          click_on review.nices_count.to_s
        end

        expect(current_path).to eq(shop_reviews_path(review.shop))
        expect(page).to have_content("いいねを取り消しました")
        expect(page).to have_selector("i.far.fa-heart.small-like-btn")
        expect(page).to have_content(review.nices_count - 1)
        review.reload
        expect(review.nices_count).to eq(0)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        visit shop_reviews_path(shop)
        review.reload
      end

      it "レビューを削除できず、ログインページに遷移すること" do
        within ".reviews-nice" do
          click_on review.nices_count.to_s
        end

        expect(current_path).to eq(new_user_session_path)
      end
    end
  end
end
