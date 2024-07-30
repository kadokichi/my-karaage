require 'rails_helper'

RSpec.describe "Shops", type: :request do
  let(:user) { create(:user) }
  let(:shop) { create(:shop, user: user) }

  before do
    sign_in user
  end

  describe "GET shops/show" do
    it "店舗詳細ページにアクセスでき、店舗の情報や店舗の地図が含まれていること" do
      get shop_path(shop)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('<img class="shop-image-size"')
      expect(response.body).to include(shop.name)
      expect(response.body).to include(shop.address)
      expect(response.body).to include(shop.product_name)
      expect(response.body).to include(shop.taste)
      expect(response.body).to include(shop.price.to_s)
      expect(response.body).to include(shop.description)
      expect(response.body).to include(shop.shop_url)
      expect(response.body).to include(shop.likes_count.to_s)
      expect(response.body).to include('div id="map"')
      expect(response.body).to include("function initMap()")
    end
  end

  describe "GET shops/new" do
    it "店舗作成ページにアクセスできること" do
      get new_shop_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST shops/create" do
    before do
      get new_shop_path
    end

    context "有効なパラメーターを持つ場合" do
      it "新規店舗が作成できること" do
        shop_params = attributes_for(:shop, user: user)
        post shops_path, params: { shop: shop_params }

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("新しい店舗を登録しました!")
      end
    end

    context "有効なパラメーターを持たない場合" do
      it "新規店舗が作成できないこと" do
        shop_params = attributes_for(:shop, name: nil, user: user)
        post shops_path, params: { shop: shop_params }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("店舗名を入力してください")
      end
    end
  end

  describe "GET shops/edit" do
    it "店舗編集ページにアクセスでき、店舗情報が含まれていること" do
      get edit_shop_path(shop)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(shop.name)
      expect(response.body).to include(shop.address)
      expect(response.body).to include(shop.product_name)
      expect(response.body).to include(shop.taste)
      expect(response.body).to include(shop.price.to_s)
      expect(response.body).to include(shop.description)
      expect(response.body).to include(shop.shop_url)
    end
  end

  describe "PATCH shops/update" do
    before do
      get edit_shop_path(shop)
    end

    context "有効なパラメーターを持つ場合" do
      it "店舗を更新し、店舗詳細ページにリダイレクトすること" do
        patch shop_path(shop), params: { shop: { name: "Updated Shop Name" } }
        shop.reload
        expect(shop.name).to eq("Updated Shop Name")
        expect(response).to redirect_to(shop)
      end
    end

    context "有効なパラメーターを持たない場合" do
      it "店舗を更新しない" do
        patch shop_path(shop), params: { shop: { name: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("店舗名を入力してください")
      end
    end
  end

  describe "DELETE shops/destroy" do
    it "店舗を削除し、ホーム画面にリダイレクトすること" do
      shop
      expect { delete shop_path(shop) }.to change(Shop, :count).by(-1)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET shops/search" do
    let!(:another_user) { create(:another_user) }
    let!(:guest_user) { create(:guest_user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:shop2) { create(:shop2, user: user) }
    let!(:shop3) { create(:shop3, user: user) }
    let!(:shop4) { create(:shop4, user: user) }
    let!(:shop5) { create(:shop5, user: user) }

    before do
      create(:like, shop: shop4, user: user)
      create(:like, shop: shop4, user: another_user)
      create(:like, shop: shop4, user: guest_user)

      create(:like, shop: shop3, user: user)
      create(:like, shop: shop3, user: another_user)

      create(:like, shop: shop2, user: user)
    end

    context "エリア検索時" do
      it "エリア検索結果を返すこと" do
        get search_shops_path, params: { address: "東京" }
        expect(response).to have_http_status(:success)
        expect([shop3]).to match_array([shop3])
        expect(response.body).not_to include(shop.name, shop2.name, shop4.name, shop5.name)
      end
    end

    context "キーワード入力時" do
      it "キーワード検索結果を返すこと" do
        get search_shops_path, params: { word: "Test" }
        expect(response).to have_http_status(:success)
        expect([shop, shop4, shop5]).to match_array([shop, shop4, shop5])
        expect(response.body).not_to include(shop2.name, shop3.name)
      end
    end

    context "濃い味系ソート時" do
      it "濃い味系の検索結果を返すこと" do
        get search_shops_path, params: { taste: "濃い味系" }
        expect(response).to have_http_status(:success)
        expect([shop, shop2, shop5]).to match_array([shop, shop2, shop5])
        expect(response.body).not_to include(shop3.name, shop4.name)
      end
    end

    context "あっさり系ソート時" do
      it "あっさり系の検索結果を返すこと" do
        get search_shops_path, params: { taste: "あっさり系" }
        expect(response).to have_http_status(:success)
        expect([shop3, shop4]).to match_array([shop3, shop4])
        expect(response.body).not_to include(shop.name, shop2.name, shop5.name)
      end
    end

    context "新着順ソート時" do
      it "新着順にショップを返すこと" do
        get search_shops_path, params: { sort: "latest" }
        expect(response).to have_http_status(:success)
        expect([shop5, shop4, shop3, shop2, shop]).to match_array([shop5, shop4, shop3, shop2, shop])
      end
    end

    context "古い順ソート時" do
      it "古い順にショップを返すこと" do
        get search_shops_path, params: { sort: "oldest" }
        expect(response).to have_http_status(:success)
        expect([shop, shop2, shop3, shop4, shop5]).to match_array([shop, shop2, shop3, shop4, shop5])
      end
    end

    context "人気順ソート時" do
      it "いいね数の多い順にショップを返すこと" do
        get search_shops_path, params: { sort: "popular" }
        expect(response).to have_http_status(:success)
        expect([shop4, shop3, shop2, shop, shop5]).to match_array([shop4, shop3, shop2, shop, shop5])
      end
    end

    context "エリア検索&キーワード検索時" do
      it "エリア、キーワード検索結果を返すこと" do
        get search_shops_path, params: { address: "東京", word: "Test" }
        expect(response).to have_http_status(:success)
        expect([]).to match_array([])
        expect(response.body).not_to include(shop.name, shop2.name, shop3.name, shop4.name, shop5.name)
      end
    end

    context "エリア検索&キーワード検索&味の検索時" do
      it "エリア、キーワード、味の検索結果を返すこと" do
        get search_shops_path, params: { address: "Test", word: "Test", taste: "濃い味系" }
        expect(response).to have_http_status(:success)
        expect([shop, shop5]).to match_array([shop, shop5])
        expect(response.body).not_to include(shop2.name, shop3.name, shop4.name)
      end
    end

    context "エリア検索&キーワード検索&味の検索&ソート(人気順)時" do
      it "エリア、キーワード、味の検索結果を人気順で返すこと" do
        get search_shops_path, params: { address: "Test", word: "Test", taste: "濃い味系", sort: "popular" }
        expect(response).to have_http_status(:success)
        expect([shop, shop5]).to match_array([shop, shop5])
        expect(response.body).not_to include(shop2.name, shop3.name, shop4.name)
      end
    end

    context "エリア検索&キーワード検索&味の検索&ソート(新しい順)時" do
      it "エリア、キーワード、味の検索結果を新しい順返すこと" do
        get search_shops_path, params: { address: "Test", word: "Test", taste: "濃い味系", sort: "latest" }
        expect(response).to have_http_status(:success)
        expect([shop5, shop]).to match_array([shop5, shop])
        expect(response.body).not_to include(shop2.name, shop3.name, shop4.name)
      end
    end

    context "エリア検索&キーワード検索&味の検索&ソート(古い順)時" do
      it "エリア、キーワード、味の検索結果を古い順で返すこと" do
        get search_shops_path, params: { address: "Test", word: "Test", taste: "濃い味系", sort: "oldest" }
        expect(response).to have_http_status(:success)
        expect([shop, shop5]).to match_array([shop, shop5])
        expect(response.body).not_to include(shop2.name, shop3.name, shop4.name)
      end
    end

    context "何も検索の条件を指定しない時" do
      it "全ての店舗を返すこと" do
        get search_shops_path, params: {}
        expect(response).to have_http_status(:success)
        expect(response.body).to include(shop.name, shop2.name, shop3.name, shop4.name, shop5.name)
      end
    end
  end
end
