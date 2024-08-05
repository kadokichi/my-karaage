require 'rails_helper'

RSpec.describe "Reviews", type: :system do
  let!(:user) { create(:user) }
  let!(:shop) { create(:shop, user: user) }

  describe "レビューの表示" do
    let!(:review) { create(:review, shop: shop, user: user) }
    let!(:another_user) { create(:another_user) }

    context "ログインユーザーがレビュー作成ユーザーの場合" do
      before do
        sign_in user
        visit shop_reviews_path(shop)
      end

      it "店舗のレビューが表示されること" do
        expect(page).to have_content("Test review content")
        expect(page).to have_content("3")
        expect(page).to have_content(user.name)
      end

      it "ユーザーをクリックすると、ユーザーページにリダイレクトされること" do
        within ".review-card" do
          click_on user.name
        end

        expect(current_path).to eq(user_path(user))
      end

      it "レビューを書くボタンが表示されないこと" do
        expect(page).not_to have_content("レビューを書く")
      end

      it "レビューの編集・削除ボタンが表示されること" do
        within ".review-actions" do
          expect(page).to have_content("編集")
          expect(page).to have_content("削除")
        end
      end

      it "レビューボタンをクリックするとレビューの編集ページにアクセスできること" do
        within ".review-actions" do
          click_on "編集"
        end

        expect(current_path).to eq(edit_shop_review_path(shop, review))
      end
    end

    context "ログインユーザーがレビューを未作成の場合" do
      before do
        sign_in another_user
        visit shop_reviews_path(shop)
      end

      it "店舗のレビューが表示されること" do
        expect(page).to have_content("Test review content")
        expect(page).to have_content("3")
        expect(page).to have_content(user.name)
      end

      it "ユーザーをクリックすると、ユーザーページにリダイレクトされること" do
        within ".review-card" do
          click_on user.name
        end

        expect(current_path).to eq(user_path(user))
      end

      it "レビューを書くボタンが表示されること" do
        expect(page).to have_content("レビューを書く")
      end

      it "レビューの編集・削除ボタンが表示されないこと" do
        expect(page).not_to have_content("編集")
        expect(page).not_to have_content("削除")
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        visit shop_reviews_path(shop)
      end

      it "店舗のレビューが表示されること" do
        expect(page).to have_content("Test review content")
        expect(page).to have_content("3")
        expect(page).to have_content(user.name)
      end

      it "ユーザーをクリックすると、ユーザーページにリダイレクトされること" do
        within ".review-card" do
          click_on user.name
        end

        expect(current_path).to eq(user_path(user))
      end

      it "レビューを書くボタンが表示されないこと" do
        expect(page).not_to have_content("レビューを書く")
      end

      it "レビューの編集・削除ボタンが表示されないこと" do
        expect(page).not_to have_content("編集")
        expect(page).not_to have_content("削除")
      end
    end
  end

  describe "レビューの作成" do
    context "ログインユーザーがレビュー未作成の場合" do
      before do
        sign_in user
        visit new_shop_review_path(shop)
      end

      it "新しいレビューを作成でき、レビュー画面にレビューが表示されていること" do
        select "5", from: "お店の評価"
        fill_in "口コミ", with: "This is a new review"
        click_button "保存"

        expect(current_path).to eq(shop_path(shop))
        expect(page).to have_content("レビューを投稿しました!")

        click_on "口コミ"
        expect(current_path).to eq(shop_reviews_path(shop))
        expect(page).to have_content(user.name)
        expect(page).to have_content("This is a new review")
        expect(page).to have_content("5")
      end

      it "入力項目に不備がある場合はレビュー作成ができず、エラーメッセージが表示されること" do
        select "5", from: "お店の評価"
        fill_in "口コミ", with: ""
        click_button "保存"

        expect(page).to have_content("口コミを入力してください")
      end
    end

    context "ログインユーザーがレビューを既に作成している場合" do
      let!(:review) { create(:review, shop: shop, user: user) }
      before do
        sign_in user
        visit new_shop_review_path(shop)
      end

      it "新しいレビューは作成できず、エラーメッセージが表示されること" do
        select "5", from: "お店の評価"
        fill_in "口コミ", with: "This is a new review"
        click_button "保存"

        expect(page).to have_content("Userはすでに存在します")
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        visit new_shop_review_path(shop)
      end

      it "ログインしていない状態でレビュー作成ページに入ると、ログインページに遷移すること" do
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_content("ログインもしくはアカウント登録してください。")
      end
    end
  end

  describe "レビューの編集" do
    let!(:review) { create(:review, shop: shop, user: user) }
    let!(:another_user) { create(:another_user) }

    context "ログインユーザーがレビュー未作成の場合" do
      before do
        sign_in user
        visit edit_shop_review_path(shop, review)
      end

      it "店舗のレビューが表示されること" do
        expect(page).to have_content("3")
        expect(page).to have_content("Test review content")
      end

      it "既存のレビューを編集でき、レビュー画面が更新されていること" do
        select "4", from: "お店の評価"
        fill_in "口コミ", with: "Test new review content"
        click_button "保存"

        expect(current_path).to eq(shop_path(shop))
        expect(page).to have_content("レビューを更新しました!")

        click_on "口コミ"
        expect(current_path).to eq(shop_reviews_path(shop))
        expect(page).to have_content(user.name)
        expect(page).to have_content("Test new review content")
        expect(page).to have_content("4")
      end

      it "入力項目に不備がある場合はレビュー更新できず、エラーメッセージが表示されること" do
        select "5", from: "お店の評価"
        fill_in "口コミ", with: ""
        click_button "保存"

        expect(page).to have_content("口コミを入力してください")
      end
    end

    context "レビュー作成ユーザー以外がレビューを更新しようとする場合" do
      before do
        sign_in another_user
        visit edit_shop_review_path(shop, review)
      end

      it "レビュー作成ユーザー以外がレビュー編集ページに入ると、トップページに遷移すること" do
        expect(current_path).to eq(root_path)
        expect(page).to have_content("権限がありません。")
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        visit edit_shop_review_path(shop, review)
      end

      it "ログインしていない状態でレビュー編集ページに入ると、ログインページに遷移すること" do
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_content("ログインもしくはアカウント登録してください。")
      end
    end
  end

  describe "レビューの削除" do
    let!(:review) { create(:review, shop: shop, user: user) }
    before do
      sign_in user
      visit shop_reviews_path(shop)
    end

    it "既存のレビューを削除でき、レビュー画面からも削除できていること" do
      within ".review-actions" do
        click_on "削除"
      end

      expect(page).to have_current_path(shop_path(review.shop))
      expect(page).to have_content("レビューを削除しました!")

      click_on "口コミ"
      expect(page).to have_current_path(shop_reviews_path(shop))
      expect(page).not_to have_content("Test review content")
      expect(page).not_to have_content("3")
      expect(page).not_to have_content(user.name)
    end
  end

  describe "パンくずリスト" do
    let!(:user) { create(:user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, shop: shop, user: user) }

    context "レビュー作成画面の場合" do
      before do
        sign_in user
        visit new_shop_review_path(shop)
      end

      it "店舗の作成画面でパンくずリストが表示されていること" do
        within ".container" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content("検索結果")
          expect(page).to have_content(shop.name)
          expect(page).to have_content("#{shop.name} のレビュー")
          expect(page).to have_content("レビューを書く")
        end
      end

      it "ホームをクリックするとトップページに遷移すること" do
        within ".container" do
          expect(page).to have_content("ホーム")
          click_on "ホーム"
        end

        expect(current_path).to eq(root_path)
      end

      it "検索結果をクリックすると店舗検索ページに遷移すること" do
        within ".container" do
          expect(page).to have_content("検索結果")
          click_on "検索結果"
        end

        expect(current_path).to eq(search_shops_path)
      end

      it "店舗名をクリックすると店舗詳細ページに遷移すること" do
        within ".container" do
          expect(page).to have_content(shop.name)
          click_on shop.name
        end

        expect(current_path).to eq(shop_path(shop))
      end

      it "店舗のレビューをクリックすると店舗レビューページに遷移すること" do
        within ".container" do
          expect(page).to have_content("#{shop.name} のレビュー")
          click_on "#{shop.name} のレビュー"
        end

        expect(current_path).to eq(shop_reviews_path(shop))
      end
    end

    context "レビュー編集画面の場合" do
      before do
        sign_in user
        visit edit_shop_review_path(shop, review)
      end

      it "店舗の編集画面でパンくずリストが表示されていること" do
        within ".container" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content("検索結果")
          expect(page).to have_content(shop.name)
          expect(page).to have_content("#{shop.name} のレビュー")
          expect(page).to have_content("レビューの編集")
        end
      end

      it "ホームをクリックするとトップページに遷移すること" do
        within ".container" do
          expect(page).to have_content("ホーム")
          click_on "ホーム"
        end

        expect(current_path).to eq(root_path)
      end

      it "検索結果をクリックすると店舗検索ページに遷移すること" do
        within ".container" do
          expect(page).to have_content("検索結果")
          click_on "検索結果"
        end

        expect(current_path).to eq(search_shops_path)
      end

      it "店舗名をクリックすると店舗詳細ページに遷移すること" do
        within ".container" do
          expect(page).to have_content(shop.name)
          click_on shop.name
        end

        expect(current_path).to eq(shop_path(shop))
      end

      it "店舗のレビューをクリックすると店舗レビューページに遷移すること" do
        within ".container" do
          expect(page).to have_content("#{shop.name} のレビュー")
          click_on "#{shop.name} のレビュー"
        end

        expect(current_path).to eq(shop_reviews_path(shop))
      end
    end

    context "レビューの一覧画面の場合" do
      before do
        visit shop_reviews_path(shop)
      end

      it "レビューの一覧画面でパンくずリストが表示されていること" do
        within ".container" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content("検索結果")
          expect(page).to have_content(shop.name)
          expect(page).to have_content("#{shop.name} のレビュー")
        end
      end

      it "ホームをクリックするとトップページに遷移すること" do
        within ".container" do
          expect(page).to have_content("ホーム")
          click_on "ホーム"
        end

        expect(current_path).to eq(root_path)
      end

      it "検索結果をクリックすると店舗検索ページに遷移すること" do
        within ".container" do
          expect(page).to have_content("検索結果")
          click_on "検索結果"
        end

        expect(current_path).to eq(search_shops_path)
      end

      it "店舗名をクリックすると店舗詳細ページに遷移すること" do
        within ".container" do
          expect(page).to have_content(shop.name)
          click_on shop.name
        end

        expect(current_path).to eq(shop_path(shop))
      end
    end
  end

  describe "レビューの件数・平均点" do
    let!(:another_user) { create(:another_user) }
    let!(:review) { create(:review, shop: shop, user: user) }
    let!(:another_review) { create(:another_review, shop: shop, user: another_user) }
    let!(:review) { create(:review, shop: shop, user: user) }
    before do
      visit shop_path(shop)
    end

    it "店舗詳細ページにレビューの平均スコアが表示されていること" do
      within ".shop-details" do
        expect(page).to have_content(3.5)
      end
    end

    it "店舗詳細ページにレビューの件数が表示されていること" do
      within ".store-rating" do
        expect(page).not_to have_content("口コミ(2)件")
      end
    end
  end
end
