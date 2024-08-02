require 'rails_helper'

RSpec.describe "Shops", type: :system do
  describe "店舗の作成" do
    context "ログインしている場合" do
      let!(:user) { create(:user) }
      let!(:shop) { create(:shop, user: user) }
      let(:shop2) { build(:shop2, user: user) }
      before do
        sign_in user
        @image_path = Rails.root.join("spec/images/sample_shop_image.jpeg")
        visit new_shop_path
      end

      it "店舗作成ができ、遷移したトップページに作成店舗が表示されること" do
        attach_file(@image_path)
        fill_in "店舗名", with: shop2.name
        fill_in "住所", with: shop2.address
        fill_in "商品名", with: shop2.product_name
        select "濃い味系", from: "味の種類"
        fill_in "予算", with: shop2.price
        fill_in "お店の説明", with: shop2.description
        fill_in "お店のurl", with: shop2.shop_url
        click_button "保存"
        expect(current_path).to eq(root_path)
        expect(page).to have_content("新しい店舗を登録しました!")
        expect(page).to have_selector("img[src*='sample_shop_image.jpeg']")
        expect(page).to have_content(shop2.name)
        expect(page).to have_content(shop2.address)
        expect(page).to have_content(shop2.taste)
        expect(page).to have_content(shop2.likes_count)
      end

      it "入力項目に不備がある場合は店舗作成ができず、エラーメッセージが表示されること" do
        fill_in "店舗名", with: shop.name
        fill_in "住所", with: shop2.address
        fill_in "商品名", with: ""
        select "濃い味系", from: "味の種類"
        fill_in "予算", with: shop2.price
        fill_in "お店の説明", with: shop2.description
        fill_in "お店のurl", with: shop2.shop_url
        click_button "保存"
        expect(page).to have_content("店舗名はすでに存在します")
        expect(page).to have_content("商品名を入力してください")
      end
    end

    context "ログインしていない場合" do
      before do
        visit new_shop_path
      end

      it "ログインしていない状態で店舗作成ページに入ると、ログインページに遷移すること" do
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_content("ログインもしくはアカウント登録してください。")
      end
    end
  end

  describe "店舗の編集" do
    let!(:user) { create(:user) }
    let!(:shop) { create(:shop, user: user) }

    context "ログインしている場合" do
      before do
        sign_in user
        visit edit_shop_path(shop)
      end

      it "店舗の情報が表示されていること" do
        expect(find_field('shop[name]').value).to eq("Test Shop")
        expect(find_field('shop[address]').value).to eq("123 Test St")
        expect(find_field('shop[product_name]').value).to eq("Test Product")
        expect(find_field('shop[taste]').value).to eq("濃い味系")
        expect(find_field('shop[price]').value).to eq("300")
        expect(find_field('shop[description]').value).to eq("Test Description 123")
        expect(find_field('shop[shop_url]').value).to eq("www.test.com")
      end

      it "店舗更新ができ、店舗詳細画面に遷移できること" do
        fill_in "店舗名", with: "New Test Shop"
        fill_in "住所", with: shop.address
        fill_in "商品名", with: shop.product_name
        select "濃い味系", from: "味の種類"
        fill_in "予算", with: shop.price
        fill_in "お店の説明", with: shop.description
        fill_in "お店のurl", with: shop.shop_url
        click_button "保存"
        expect(current_path).to eq(shop_path(shop))
        expect(page).to have_content("店舗の情報を更新しました!")
        expect(page).to have_content("New Test Shop")
      end

      it "入力項目に不備がある場合は店舗更新ができず、エラーメッセージが表示されること" do
        fill_in "店舗名", with: ""
        fill_in "住所", with: shop.address
        fill_in "商品名", with: ""
        select "濃い味系", from: "味の種類"
        fill_in "予算", with: shop.price
        fill_in "お店の説明", with: shop.description
        fill_in "お店のurl", with: shop.shop_url
        click_button "保存"
        expect(page).to have_content("店舗名を入力してください")
        expect(page).to have_content("商品名を入力してください")
      end
    end

    context "店舗作成ユーザー以外の場合" do
      let!(:another_user) { create(:another_user) }
      before do
        sign_in another_user
        visit edit_shop_path(shop)
      end

      it "店舗作成ユーザー以外が店舗編集ページに入ると、トップページに遷移すること" do
        expect(current_path).to eq(root_path)
        expect(page).to have_content("このページにアクセスする権限がありません")
      end
    end

    context "ログインしていない場合" do
      before do
        visit edit_shop_path(shop)
      end

      it "ログインしていない状態で店舗編集ページに入ると、ログインページに遷移すること" do
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_content("ログインもしくはアカウント登録してください。")
      end
    end
  end

  describe "店舗の詳細画面" do
    let!(:user) { create(:user) }
    let!(:another_user) { create(:another_user) }
    let!(:shop2) { create(:shop2, user: user) }

    context "ログインユーザーが店舗作成ユーザーの場合" do
      before do
        sign_in user
        visit shop_path(shop2)
      end

      it "店舗詳細画面に店舗情報が表示されること" do
        expect(page).to have_content(shop2.name)
        expect(page).to have_content(shop2.address)
        expect(page).to have_content(shop2.product_name)
        expect(page).to have_content(shop2.taste)
        expect(page).to have_content(shop2.price)
        expect(page).to have_content(shop2.description)
        expect(page).to have_content(shop2.shop_url)
        expect(page).to have_content(shop2.likes_count)
      end

      it "店舗詳細画面に店舗の地図が表示されること" do
        expect(page).to have_content("店舗の周辺地図")
        expect(page).to have_content("存在しない住所の場合は東京駅が表示されます")
        expect(page).to have_selector("#map")
      end

      it "店舗作成ユーザーの場合は編集、削除の項目が存在すること" do
        within ".shop-edit" do
          expect(page).to have_content("編集")
          expect(page).to have_content("削除")
        end
      end

      it "店舗作成ユーザーは編集ボタンをクリックすると、編集ページにアクセスできること" do
        within ".shop-edit" do
          click_on "編集"
        end

        expect(current_path).to eq(edit_shop_path(shop2))
      end

      it "店舗作成ユーザーは削除ボタンをクリックすると、店舗を削除しトップ画面に遷移すること" do
        within ".shop-edit" do
          click_on "削除"
        end

        expect(page).to have_current_path(root_path)
        expect(page).to have_content("店舗を削除しました!")
        expect(page).not_to have_content(shop2.name)
      end

      it "口コミリンクをクリックすると口コミページに遷移できること" do
        click_on "口コミ"
        expect(current_path).to eq(shop_reviews_path(shop2))
      end

      it "店舗のurlをクリックするとurlのページに遷移できること" do
        click_on shop2.shop_url
        expect(page).to have_current_path(shop2.shop_url, url: true)
      end
    end

    context "店舗作成ユーザー以外のユーザーの場合" do
      before do
        sign_in another_user
        visit shop_path(shop2)
      end

      it "店舗詳細画面に店舗情報が表示されること" do
        expect(page).to have_content(shop2.name)
        expect(page).to have_content(shop2.address)
        expect(page).to have_content(shop2.product_name)
        expect(page).to have_content(shop2.taste)
        expect(page).to have_content(shop2.price)
        expect(page).to have_content(shop2.description)
        expect(page).to have_content(shop2.shop_url)
        expect(page).to have_content(shop2.likes_count)
      end

      it "店舗詳細画面に店舗の地図が表示されること" do
        expect(page).to have_content("店舗の周辺地図")
        expect(page).to have_content("存在しない住所の場合は東京駅が表示されます")
        expect(page).to have_selector("#map")
      end

      it "作成ユーザーの場合は編集、削除の項目が存在しないこと" do
        within ".shop-edit" do
          expect(page).not_to have_content("編集")
          expect(page).not_to have_content("削除")
        end
      end
    end
  end

  describe "店舗の検索" do
    let!(:user) { create(:user) }
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

      visit search_shops_path
    end

    context "検索条件を指定しない場合" do
      it "検索条件を指定しない場合は全ての店舗が表示されること" do
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        expect(page).to have_content(shop.name)
        expect(page).to have_content(shop2.name)
        expect(page).to have_content(shop3.name)
        expect(page).to have_content(shop4.name)
        expect(page).to have_content(shop5.name)
      end
    end

    context "エリア検索の場合" do
      it "エリアを入力し、検索すると該当する店舗のみ表示されること" do
        fill_in "エリアを入力", with: "東京"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        expect(page).to have_content(shop3.name)
        expect(page).not_to have_content(shop.name)
        expect(page).not_to have_content(shop2.name)
        expect(page).not_to have_content(shop4.name)
        expect(page).not_to have_content(shop5.name)
      end
    end

    context "キーワード検索の場合" do
      it "キーワードを入力し、検索すると該当する店舗のみ表示されること" do
        fill_in "キーワードを入力", with: "Test"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        expect(page).to have_content(shop.name)
        expect(page).to have_content(shop4.name)
        expect(page).to have_content(shop5.name)
        expect(page).not_to have_content(shop2.name)
        expect(page).not_to have_content(shop3.name)
      end
    end

    context "濃い味系をソートする場合" do
      it "濃い味系の店舗のみ表示されること" do
        check "濃い味系"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        expect(page).to have_content(shop.name)
        expect(page).to have_content(shop2.name)
        expect(page).to have_content(shop5.name)
        expect(page).not_to have_content(shop3.name)
        expect(page).not_to have_content(shop4.name)
      end
    end

    context "あっさり系をソートする場合" do
      it "あっさり系の店舗のみ表示されること" do
        check "あっさり系"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        expect(page).to have_content(shop3.name)
        expect(page).to have_content(shop4.name)
        expect(page).not_to have_content(shop.name)
        expect(page).not_to have_content(shop2.name)
        expect(page).not_to have_content(shop5.name)
      end
    end

    context "店舗を新着順にソートする場合" do
      it "店舗が新しい順に表示されること" do
        check "新着順"
        click_on "検索"
        within ".all-shops" do
          expect(page.all(".shop-details")[0]).to have_content(shop5.name)
          expect(page.all(".shop-details")[1]).to have_content(shop4.name)
          expect(page.all(".shop-details")[2]).to have_content(shop3.name)
          expect(page.all(".shop-details")[3]).to have_content(shop2.name)
          expect(page.all(".shop-details")[4]).to have_content(shop.name)
        end
      end
    end

    context "店舗を古い順にソートする場合" do
      it "店舗が古い順に表示されること" do
        check "古い順"
        click_on "検索"
        within ".all-shops" do
          expect(page.all(".shop-details")[0]).to have_content(shop.name)
          expect(page.all(".shop-details")[1]).to have_content(shop2.name)
          expect(page.all(".shop-details")[2]).to have_content(shop3.name)
          expect(page.all(".shop-details")[3]).to have_content(shop4.name)
          expect(page.all(".shop-details")[4]).to have_content(shop5.name)
        end
      end
    end

    context "店舗を人気順にソートする場合" do
      it "店舗が人気順に表示されること" do
        check "人気順"
        click_on "検索"
        within ".all-shops" do
          expect(page.all(".shop-details")[0]).to have_content(shop4.name)
          expect(page.all(".shop-details")[1]).to have_content(shop3.name)
          expect(page.all(".shop-details")[2]).to have_content(shop2.name)
          expect(page.all(".shop-details")[3]).to have_content(shop5.name)
          expect(page.all(".shop-details")[4]).to have_content(shop.name)
        end
      end
    end

    context "エリア検索&キーワード検索する場合" do
      it "エリア、キーワード検索結果を表示すること" do
        fill_in "エリアを入力", with: "東京"
        fill_in "キーワードを入力", with: "Test"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        expect(page).not_to have_content(shop.name)
        expect(page).not_to have_content(shop2.name)
        expect(page).not_to have_content(shop3.name)
        expect(page).not_to have_content(shop4.name)
        expect(page).not_to have_content(shop5.name)
      end
    end

    context "エリア検索&キーワード検索&味の検索の場合" do
      it "エリア、キーワード、味の検索結果を表示すること" do
        fill_in "エリアを入力", with: "Test"
        fill_in "キーワードを入力", with: "Test"
        check "濃い味系"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        expect(page).to have_content(shop.name)
        expect(page).to have_content(shop5.name)
        expect(page).not_to have_content(shop2.name)
        expect(page).not_to have_content(shop3.name)
        expect(page).not_to have_content(shop4.name)
      end
    end

    context "エリア検索&キーワード検索&味の検索&ソート(人気順)の場合" do
      before do
        create(:like, shop: shop, user: user)
      end

      it "エリア、キーワード、味の検索結果を人気順で表示すること" do
        fill_in "エリアを入力", with: "Test"
        fill_in "キーワードを入力", with: "Test"
        check "濃い味系"
        check "人気順"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        within ".all-shops" do
          expect(page.all(".shop-details")[0]).to have_content(shop.name)
          expect(page.all(".shop-details")[1]).to have_content(shop5.name)
        end
        expect(page).not_to have_content(shop2.name)
        expect(page).not_to have_content(shop3.name)
        expect(page).not_to have_content(shop4.name)
      end
    end

    context "エリア検索&キーワード検索&味の検索&ソート(新しい順)の場合" do
      it "エリア、キーワード、味の検索結果を人気順で表示すること" do
        fill_in "エリアを入力", with: "Test"
        fill_in "キーワードを入力", with: "Test"
        check "濃い味系"
        check "新着順"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        within ".all-shops" do
          expect(page.all(".shop-details")[0]).to have_content(shop5.name)
          expect(page.all(".shop-details")[1]).to have_content(shop.name)
        end
        expect(page).not_to have_content(shop2.name)
        expect(page).not_to have_content(shop3.name)
        expect(page).not_to have_content(shop4.name)
      end
    end

    context "エリア検索&キーワード検索&味の検索&ソート(古い順)の場合" do
      it "エリア、キーワード、味の検索結果を古い順で表示すること" do
        fill_in "エリアを入力", with: "Test"
        fill_in "キーワードを入力", with: "Test"
        check "濃い味系"
        check "古い順"
        click_on "検索"
        expect(current_path).to eq(search_shops_path)
        within ".all-shops" do
          expect(page.all(".shop-details")[0]).to have_content(shop.name)
          expect(page.all(".shop-details")[1]).to have_content(shop5.name)
        end
        expect(page).not_to have_content(shop2.name)
        expect(page).not_to have_content(shop3.name)
        expect(page).not_to have_content(shop4.name)
      end
    end
  end

  describe "パンくずリスト" do
    let!(:user) { create(:user) }
    let!(:shop) { create(:shop, user: user) }

    context "店舗編集画面の場合" do
      before do
        sign_in user
        visit edit_shop_path(shop)
      end

      it "店舗の編集画面でパンくずリストが表示されていること" do
        within ".shop-container" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content("検索結果")
          expect(page).to have_content(shop.name)
          expect(page).to have_content("店舗の編集")
        end
      end

      it "ホームをクリックするとトップページに遷移すること" do
        within ".shop-container" do
          expect(page).to have_content("ホーム")
          click_on "ホーム"
        end
        expect(current_path).to eq(root_path)
      end

      it "検索結果をクリックすると店舗検索ページに遷移すること" do
        within ".shop-container" do
          expect(page).to have_content("検索結果")
          click_on "検索結果"
        end
        expect(current_path).to eq(search_shops_path)
      end

      it "店舗名をクリックすると店舗詳細ページに遷移すること" do
        within ".shop-container" do
          expect(page).to have_content(shop.name)
          click_on shop.name
        end
        expect(current_path).to eq(shop_path(shop))
      end
    end

    context "店舗作成画面の場合" do
      before do
        sign_in user
        visit new_shop_path
      end

      it "店舗の作成画面でパンくずリストが表示されていること" do
        within ".shop-container" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content("お店を登録")
        end
      end

      it "ホームをクリックするとトップページに遷移すること" do
        within ".shop-container" do
          expect(page).to have_content("ホーム")
          click_on "ホーム"
        end
        expect(current_path).to eq(root_path)
      end
    end

    context "店舗詳細画面の場合" do
      before do
        sign_in user
        visit shop_path(shop)
      end

      it "店舗の編集画面でパンくずリストが表示されていること" do
        within ".shop-container" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content("検索結果")
          expect(page).to have_content(shop.name)
        end
      end

      it "ホームをクリックするとトップページに遷移すること" do
        within ".shop-container" do
          expect(page).to have_content("ホーム")
          click_on "ホーム"
        end
        expect(current_path).to eq(root_path)
      end

      it "検索結果をクリックすると店舗検索ページに遷移すること" do
        within ".shop-container" do
          expect(page).to have_content("検索結果")
          click_on "検索結果"
        end
        expect(current_path).to eq(search_shops_path)
      end
    end

    context "店舗検索画面の場合" do
      before do
        visit search_shops_path
      end

      it "店舗の検索画面でパンくずリストが表示されていること" do
        within ".container" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content("検索結果")
        end
      end

      it "ホームをクリックするとトップページに遷移すること" do
        within ".container" do
          expect(page).to have_content("ホーム")
          click_on "ホーム"
        end
        expect(current_path).to eq(root_path)
      end
    end
  end
end
