require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    let!(:user) { create(:user) }
    let!(:click_users) { create_list(:click_user, 6) }
    let!(:popular_shops) do
      shops = create_list(:popular_shop, 6, user: user)
      shops.each_with_index do |shop, index|
        create_list(:like, 6 - index, shop: shop, user: click_users.sample)
      end
      shops
    end
    let!(:new_shops) { create_list(:new_shop, 6, user: user) }

    before do
      get root_path
    end

    it "ホーム画面にアクセスできること" do
      expect(response).to have_http_status(:success)
      expect(response.body).to include("あなたのお気に入りのからあげを探そう＆シェアしよう!!")
    end

    it "新着店舗に1~5番目に新しい店舗含まれていること" do
      expect(new_shops.first(5)).to match_array(new_shops.first(5))
      new_shops[5..1].each do |shop|
        expect(response.body).to include(shop.name)
      end
    end

    it "新着店舗に6番目に新しい店舗含まれていないこと" do
      expect(response.body).not_to include(new_shops[0].name)
    end

    it "人気の店舗に1~5番目に人気の店舗含まれていること" do
      popular_shops.each(&:reload)
      expect(popular_shops.first(5)).to match_array(popular_shops.first(5))

      popular_shops[0..4].each do |shop|
        expect(response.body).to include(shop.name)
      end

      expect(popular_shops[0].likes_count).to eq(6)
      expect(popular_shops[1].likes_count).to eq(5)
      expect(popular_shops[2].likes_count).to eq(4)
      expect(popular_shops[3].likes_count).to eq(3)
      expect(popular_shops[4].likes_count).to eq(2)
    end

    it "人気の店舗に6番目に人気の店舗含まれていないこと" do
      popular_shops.each(&:reload)
      expect(response.body).not_to include(popular_shops[5].name)
      expect(popular_shops[5].likes_count).to eq(1)
    end
  end
end
