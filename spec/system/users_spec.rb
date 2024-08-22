require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe "ユーザーのログイン" do
    context "既にユーザー登録している場合" do
      let!(:user) { create(:user) }
      before do
        visit new_user_session_path
      end

      it "ログインを成功させ、ホームページに遷移できること" do
        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password
        click_button "ログイン"
        expect(current_path).to eq(root_path)
        expect(page).to have_content("ログインしました")
        expect(page).to have_content("アカウント")
        expect(page).to have_content("店舗登録")
        expect(page).to have_content("お問い合わせ")
        expect(page).to have_content("ログアウト")
      end

      it "メールアドレスorパスワードが正しくない場合は、ログインできないこと" do
        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: "a" * 8
        click_button "ログイン"
        expect(page).to have_content("メールアドレスまたはパスワードが違います。")
      end
    end

    context "ゲストログインをする場合" do
      it "ゲストユーザーでログインできること" do
        visit root_path
        click_on "ゲストログイン", match: :first
        expect(current_path).to eq(root_path)
        expect(page).to have_content("ゲストユーザーとしてログインしました!")
        expect(page).to have_content("アカウント")
        expect(page).to have_content("店舗登録")
        expect(page).to have_content("お問い合わせ")
        expect(page).to have_content("ログアウト")
      end
    end
  end

  describe "新規ユーザー作成" do
    let(:user) { build(:user) }
    let!(:another_user) { create(:another_user) }
    before do
      visit new_user_registration_path
    end

    it "新規ユーザー登録を成功させ、ホームページに遷移できること" do
      fill_in "ユーザー名", with: user.name
      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      fill_in "パスワード確認", with: user.password_confirmation
      click_button "新規作成"
      expect(current_path).to eq(root_path)
      expect(page).to have_content("アカウント登録が完了しました。")
    end

    it "既に使用されている名前、メールアドレスでは新規ユーザー登録ができないこと" do
      fill_in "ユーザー名", with: another_user.name
      fill_in "メールアドレス", with: another_user.email
      fill_in "パスワード", with: "password"
      fill_in "パスワード確認", with: "password"
      click_button "新規作成"
      expect(page).to have_content("ユーザー名はすでに存在します")
      expect(page).to have_content("メールアドレスはすでに存在します")
    end
  end

  describe "ユーザープロフィールの更新" do
    context "既にユーザー登録している場合" do
      let!(:user) { create(:user) }
      let!(:another_user) { create(:another_user) }
      before do
        sign_in user
        @image_path = Rails.root.join("spec/images/sample_user_image.png")
        visit edit_user_path(user)
      end

      it "名前と画像を変更できること" do
        attach_file(@image_path)
        fill_in "名前", with: "New Test User"
        click_button "保存"
        expect(current_path).to eq(user_path(user))
        expect(page).to have_content("ユーザー情報を更新しました!")
        expect(page).to have_content("New Test User")
        expect(page).to have_selector("img[src*='sample_user_image.png']")
      end

      it "既に使用されている名前には変更できないこと" do
        fill_in "名前", with: another_user.name
        click_button "保存"
        expect(page).to have_content("ユーザー名はすでに存在します")
      end

      it "登録ユーザーのプロフィールを登録ユーザー以外が更新しようとするとホームにリダイレクトされること" do
        visit edit_user_path(another_user)
        expect(current_path).to eq(root_path)
      end
    end

    context "ゲストログインしている場合" do
      let!(:guest_user) { create(:guest_user) }
      before do
        sign_in guest_user
      end

      it "ゲストユーザーはプロフィールの変更ができず、ホーム画面に遷移すること" do
        visit edit_user_path(guest_user)
        expect(current_path).to eq(root_path)
        expect(page).to have_content("ゲストユーザーの情報は変更できません。")
      end
    end
  end

  describe "ユーザーアカウントの更新" do
    context "既にユーザー登録している場合" do
      let!(:user) { create(:user) }
      let!(:another_user) { create(:another_user) }
      before do
        sign_in user
        visit edit_user_registration_path
      end

      it "メールアドレスとパスワードを変更できること" do
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "新しいパスワード", with: "newpassword"
        fill_in "新しいパスワード確認", with: "newpassword"
        fill_in "現在のパスワード", with: "password"
        click_button "保存"
        expect(current_path).to eq(user_path(user))
        expect(page).to have_content("アカウント情報を変更しました。")
      end

      it "既に使用されているメースアドレスには変更できないこと" do
        fill_in "メールアドレス", with: "another_test@example.com"
        fill_in "現在のパスワード", with: "password"
        click_button "保存"
        expect(page).to have_content("メールアドレスはすでに存在します")
      end

      it "現在のパスワードを入力しないと変更できないこと" do
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "新しいパスワード", with: "newpassword"
        fill_in "新しいパスワード確認", with: "newpassword"
        fill_in "現在のパスワード", with: ""
        click_button "保存"
        expect(page).to have_content("現在のパスワードを入力してください")
      end
    end

    context "ゲストログインしている場合" do
      let!(:guest_user) { create(:guest_user) }
      before do
        sign_in guest_user
        visit edit_user_registration_path
      end

      it "ゲストユーザーはアカウントの変更ができず、ホーム画面に遷移すること" do
        expect(current_path).to eq(root_path)
        expect(page).to have_content("ゲストユーザーの情報は変更できません。")
      end
    end
  end

  describe "ユーザー画面のパンくずリスト" do
    context "ユーザー詳細画面" do
      let!(:user) { create(:user) }
      before do
        sign_in user
        visit user_path(user)
      end

      it "パンくずリストにホームとユーザー名が表示されていて、ホームをクリックするとホームに遷移できること" do
        within ".breadcrumb" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content(user.name)
          click_on "ホーム"
          expect(current_path).to eq root_path
        end
      end
    end

    context "ユーザープロフィール編集画面" do
      let!(:user) { create(:user) }
      before do
        sign_in user
        visit edit_user_path(user)
      end

      it "パンくずリストにホーム,ユーザー名,プロフィール編集が表示されていて、ホームをクリックするとホームに遷移できること" do
        within ".breadcrumb" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content(user.name)
          expect(page).to have_content("プロフィール編集")
          click_on "ホーム"
          expect(current_path).to eq root_path
        end
      end

      it "パンくずリストにホーム,ユーザー名,プロフィール編集が表示されていて、ユーザー名をクリックするとユーザー画面に遷移できること" do
        within ".breadcrumb" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content(user.name)
          expect(page).to have_content("プロフィール編集")
          click_on user.name
          expect(current_path).to eq user_path(user)
        end
      end
    end

    context "ユーザーアカウント編集画面" do
      let!(:user) { create(:user) }
      before do
        sign_in user
        visit edit_user_registration_path
      end

      it "パンくずリストにホーム,ユーザー名,アカウント編集が表示されていて、ホームをクリックするとホームに遷移できること" do
        within ".breadcrumb" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content(user.name)
          expect(page).to have_content("アカウント編集")
          click_on "ホーム"
          expect(current_path).to eq root_path
        end
      end

      it "パンくずリストにホーム,ユーザー名,アカウント編集が表示されていて、ユーザー名をクリックするとユーザー画面に遷移できること" do
        within ".breadcrumb" do
          expect(page).to have_content("ホーム")
          expect(page).to have_content(user.name)
          expect(page).to have_content("アカウント編集")
          click_on user.name
          expect(current_path).to eq user_path(user)
        end
      end
    end
  end

  describe 'ユーザー詳細画面' do
    let!(:user) { create(:user) }
    let!(:another_user) { create(:another_user) }
    let!(:created_shop) { create(:shop, user: user) }
    let!(:liked_shop) { create(:shop2, user: another_user) }
    let!(:like) { create(:like, user: user, shop: liked_shop) }

    before do
      sign_in user
      visit user_path(user)
    end

    it 'ユーザーが作成した店舗が表示されており、詳細ボタンをクリックすると店舗詳細ページに遷移できること' do
      within ".new-shops" do
        expect(page).to have_css("div.shop-image img", visible: true)
        expect(page).to have_content(created_shop.name)
        expect(page).to have_content(created_shop.address)
        expect(page).to have_content(created_shop.taste)
        click_on "詳しくはこちら"
        expect(current_path).to eq(shop_path(created_shop))
      end
    end

    it 'ユーザーがいいねした店舗が表示されており、詳細ボタンをクリックすると店舗詳細ページに遷移できること' do
      within ".popular-shops" do
        liked_shop.reload
        expect(page).to have_css("div.shop-image img", visible: true)
        expect(page).to have_content(liked_shop.name)
        expect(page).to have_content(liked_shop.address)
        expect(page).to have_content(liked_shop.taste)
        expect(liked_shop.likes_count).to eq(1)
        click_on "詳しくはこちら"
        expect(current_path).to eq(shop_path(liked_shop))
      end
    end
  end
end
