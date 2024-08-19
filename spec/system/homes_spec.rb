require 'rails_helper'

RSpec.describe 'Homes', type: :system do
  context "ホーム画面に店舗が存在する場合" do
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
      visit root_path
    end

    it "1~5番目に新しい店舗が表示されていること" do
      within('.new-shops') do
        new_shops[5..1].each do |shop|
          expect(page).to have_content(shop.name)
          expect(page).to have_content(shop.address)
          expect(page).to have_content(shop.taste)
          expect(page).to have_content(shop.likes.count.to)
        end
      end
    end

    it "6番目に新しい店舗が表示されていないこと" do
      within('.new-shops') do
        expect(page).not_to have_content(new_shops[0].name)
        expect(page).not_to have_content(new_shops[0].address)
      end
    end

    it "1~5番目に人気な店舗が表示されていること" do
      within('.popular-shops') do
        popular_shops[0..4].each do |shop|
          expect(page).to have_content(shop.name)
          expect(page).to have_content(shop.address)
          expect(page).to have_content(shop.taste)
          expect(page).to have_content(shop.likes.count)
        end
      end
    end

    it "6番目に人気な店舗が表示されていないこと" do
      within('.popular-shops') do
        expect(page).not_to have_content(popular_shops[5].name)
        expect(page).not_to have_content(popular_shops[5].address)
      end
    end

    it "詳しくはこちらボタンをクリックすると、店舗詳細ページに遷移すること" do
      within('.shop-item', match: :first) do
        click_on "詳しくはこちら"
      end

      expect(current_path).to eq("/shops/#{Shop.last.id}")
    end

    it "新しい店舗をもっと見るボタンをクリックすると、店舗の検索ページ(新着順)に遷移すること" do
      within('.new-shops') do
        click_on "新しい店舗をもっと見る"
        expect(current_url).to eq("#{root_url}shops/search?sort=latest")
      end
    end

    it "人気の店舗をもっと見るボタンをクリックすると、店舗の検索ページ(新着順)に遷移すること" do
      within('.popular-shops') do
        click_on "人気の店舗をもっと見る"
        expect(current_url).to eq("#{root_url}shops/search?sort=popular")
      end
    end
  end

  context "ホーム画面に店舗が存在しない場合" do
    before do
      visit root_path
    end

    it "新しい店舗が表示されていないこと" do
      within('.new-shops') do
        expect(page).to have_content("新着店舗はまだありません")
      end
    end

    it "人気の店舗が表示されていないこと" do
      within('.popular-shops') do
        expect(page).to have_content("人気の店舗はまだありません")
      end
    end
  end

  context "ホームリンク、お問い合わせへの遷移" do
    before do
      visit root_path
    end

    it "ホームリンクをクリックすると、ホーム画面に遷移すること" do
      within('.header') do
        click_on "Myからあげ"
        expect(current_path).to eq(root_path)
      end
    end

    it "お問い合わせリンクをクリックすると、お問い合わせ画面に遷移すること" do
      within('.footer') do
        click_on "お問い合わせ"
        expect(current_path).to eq(new_contact_path)
      end
    end
  end
end
