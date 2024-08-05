require 'rails_helper'

RSpec.describe "Reviews", type: :request do
  describe "GET reviews/index" do
    let!(:user) { create(:user) }
    let!(:another_user) { create(:another_user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, shop: shop, user: user) }

    context "レビューを作成したユーザーがログインしている場合" do
      before do
        sign_in user
        get shop_reviews_path(shop)
      end

      it "店舗のレビューページにアクセスでき、店舗のレビューが含まれていること" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
        expect(response.body).to include(review.score.to_s)
        expect(response.body).to include(review.content)
        expect(response.body).to include(review.nices_count.to_s)
      end

      it "既にレビューを作成したユーザーにはレビューを書くボタンが含まれないこと" do
        expect(response.body).not_to include("レビューを書く")
      end

      it "自身が作成したレビューには、編集、削除が含まれていること" do
        expect(response.body).to include("編集")
        expect(response.body).to include("削除")
      end
    end

    context "まだレビューを作成していないログインユーザーの場合" do
      before do
        sign_in another_user
        get shop_reviews_path(shop)
      end

      it "店舗のレビューページにアクセスでき、店舗のレビューが含まれていること" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
        expect(response.body).to include(review.score.to_s)
        expect(response.body).to include(review.content)
        expect(response.body).to include(review.nices_count.to_s)
      end

      it "まだレビューを書いていない場合は、レビューを書くボタンが含まれること" do
        expect(response.body).to include("レビューを書く")
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get shop_reviews_path(shop)
      end

      it "店舗のレビューページにアクセスでき、店舗のレビューが含まれていること" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
        expect(response.body).to include(review.score.to_s)
        expect(response.body).to include(review.content)
        expect(response.body).to include(review.nices_count.to_s)
      end

      it "ユーザーがログインしていない場合は、レビューを書くボタンが含まれないこと" do
        expect(response.body).not_to include("レビューを書く")
      end
    end
  end

  describe "GET reviews/new" do
    let!(:user) { create(:user) }
    let!(:shop) { create(:shop, user: user) }

    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        get new_shop_review_path(shop)
      end

      it "レビュー作成ページにアクセスできること" do
        expect(response).to have_http_status(:success)
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get new_shop_review_path(shop)
      end

      it "ログインページにリダイレクトされること" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST reviews/create" do
    let!(:user) { create(:user) }
    let!(:shop) { create(:shop, user: user) }

    before do
      sign_in user
      get new_shop_review_path(shop)
    end

    context "有効なパラメーターを持つ場合" do
      it "新規レビューが作成できること" do
        review_params = attributes_for(:review, shop: shop, user: user)
        post shop_reviews_path(shop), params: { review: review_params }
        expect(response).to redirect_to(shop_path(shop))
        follow_redirect!
        expect(response.body).to include("レビューを投稿しました!")
      end
    end

    context "有効なパラメーターを持たない場合" do
      it "新規店舗が作成できないこと" do
        review_params = attributes_for(:review, score: nil, shop: shop, user: user)
        post shop_reviews_path(shop), params: { review: review_params }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("お店の評価を入力してください")
      end
    end
  end

  describe "GET reviews/edit" do
    let!(:user) { create(:user) }
    let!(:another_user) { create(:another_user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, shop: shop, user: user) }

    context "レビューを作成したユーザーがログインしている場合" do
      before do
        sign_in user
        get edit_shop_review_path(shop, review)
      end

      it "レビュー編集ページにアクセスでき、レビュー情報が含まれていること" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include(review.score.to_s)
        expect(response.body).to include(review.content)
      end
    end

    context "レビューを作成したユーザー以外がログインしている場合" do
      before do
        sign_in another_user
        get edit_shop_review_path(shop, review)
      end

      it "トップページにリダイレクトされること" do
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("権限がありません。")
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get edit_shop_review_path(shop, review)
      end

      it "ログインページにリダイレクトされること" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH reviews/update" do
    let!(:user) { create(:user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, shop: shop, user: user) }
    before do
      sign_in user
      get edit_shop_review_path(shop, review)
    end

    context "有効なパラメーターを持つ場合" do
      it "レビューを更新し、店舗詳細ページにリダイレクトすること" do
        patch shop_review_path(shop, review), params: { review: { content: "Updated Test review content" } }
        review.reload
        expect(review.content).to eq("Updated Test review content")
        expect(response).to redirect_to(review.shop)
        follow_redirect!
        expect(response.body).to include("レビューを更新しました!")
      end
    end

    context "有効なパラメーターを持たない場合" do
      it "レビューを更新しない" do
        patch shop_review_path(shop, review), params: { review: { content: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("口コミを入力してください")
      end
    end
  end

  describe "DELETE reviews/destroy" do
    let!(:user) { create(:user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, shop: shop, user: user) }
    before do
      sign_in user
    end

    it "レビューを削除し、店舗詳細画面にリダイレクトすること" do
      review
      expect { delete shop_review_path(shop, review) }.to change(Review, :count).by(-1)
      expect(response).to redirect_to(shop_path(review.shop))
      follow_redirect!
      expect(response.body).to include("レビューを削除しました!")
    end
  end

  describe "GET shops/show" do
    let!(:user) { create(:user) }
    let!(:another_user) { create(:another_user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, shop: shop, user: user) }
    let!(:another_review) { create(:another_review, shop: shop, user: another_user) }
    let(:review_average) { ((review.score + another_review.score) / 2.0).round(2) }

    before do
      sign_in user
      get shop_path(shop)
    end

    it "店舗詳細画面にレビューの平均値、件数が含まれていること" do
      expect(response).to have_http_status(:success)
      expect(response.body).to include(review_average.to_s)
      expect(review_average).to eq(3.5)
      expect(response.body).to include(shop.reviews.count.to_s)
      expect(shop.reviews.count.to_i).to eq(2)
    end
  end

  describe "パンくずリスト" do
    let!(:user) { create(:user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, shop: shop, user: user) }
    before do
      sign_in user
    end

    context "店舗のレビュー画面の場合" do
      it "店舗のレビュー画面にパンくずリストが含まれていること" do
        get shop_reviews_path(shop)
        expect(response.body).to include('<ul class="breadcrumb">')
        expect(response.body).to include('<a href="/">ホーム</a>')
        expect(response.body).to include('<a href="/shops/search">検索結果</a>')
        expect(response.body).to include("<a href=\"/shops/#{shop.id}\">#{shop.name}</a>")
        expect(response.body).to include("#{shop.name}のレビュー")
      end
    end

    context "レビューの編集画面の場合" do
      it "レビューの編集画面にパンくずリストが含まれていること" do
        get edit_shop_review_path(shop, review)
        expect(response.body).to include('<ul class="breadcrumb">')
        expect(response.body).to include('<a href="/">ホーム</a>')
        expect(response.body).to include('<a href="/shops/search">検索結果</a>')
        expect(response.body).to include("<a href=\"/shops/#{shop.id}\">#{shop.name}</a>")
        expect(response.body).to include("<a href=\"/shops/#{shop.id}/reviews\">#{shop.name} のレビュー</a>")
        expect(response.body).to include("レビューの編集")
      end
    end

    context "レビューの作成画面の場合" do
      it "レビューの作成画面にパンくずリストが含まれていること" do
        get new_shop_review_path(shop)
        expect(response.body).to include('<ul class="breadcrumb">')
        expect(response.body).to include('<a href="/">ホーム</a>')
        expect(response.body).to include('<a href="/shops/search">検索結果</a>')
        expect(response.body).to include("<a href=\"/shops/#{shop.id}\">#{shop.name}</a>")
        expect(response.body).to include("<a href=\"/shops/#{shop.id}/reviews\">#{shop.name} のレビュー</a>")
        expect(response.body).to include("レビューを書く")
      end
    end
  end
end
