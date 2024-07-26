require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:guest_user) { FactoryBot.create(:guest_user) }
  let!(:another_user) { FactoryBot.create(:another_user) }

  describe "GET /users/edit" do
    context "ユーザーがログインしている状態" do
      before { sign_in user }

      it "ユーザーのプロフィールページにアクセスできること" do
        get edit_user_path(user)
        expect(response).to have_http_status(:success)
      end

      it "他のユーザーのプロフィールを編集しようとするとリダイレクトされること" do
        get edit_user_path(another_user)
        expect(response).to redirect_to(root_path)
      end
    end

    context "ユーザーがログインしていない状態" do
      it "他のユーザーを編集しようとするとホーム画面にリダイレクトされること" do
        get edit_user_path(user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET edit_user_registration_path" do
    context "ユーザーがログインしている状態" do
      before { sign_in user }

      it "ユーザーのアカウントページにアクセスできること" do
        get edit_user_registration_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.email)
      end
    end

    context "ユーザーがログインしていない状態" do
      it "アカウントを編集しようとするとログイン画面にリダイレクトされること" do
        get edit_user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /users/show" do
    context "ユーザーがログインしている状態" do
      before do
        sign_in user
        get user_path(user)
      end

      it "ユーザーの詳細ページにアクセスできること" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
        expect(response.body).to include('<div class="user-image">')
      end

      it "ログイン時にヘッダーに表示される項目があること" do
        expect(response.body).to include("アカウント")
        expect(response.body).to include("店舗登録")
        expect(response.body).to include("お問い合わせ")
        expect(response.body).to include("ログアウト")
      end

      it "ログインユーザーのユーザー詳細画面にはユーザーの編集項目が含まれていること" do
        expect(response.body).to include(edit_user_path(user))
        expect(response.body).to include(edit_user_registration_path)
      end
    end

    context "ユーザーがログインしていない状態" do
      before do
        get user_path(user)
      end

      it "ユーザーの詳細ページにアクセスできること" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
        expect(response.body).to include('<div class="user-image">')
      end

      it "ログインしていない時にヘッダーに表示される項目があること" do
        expect(response.body).to include("ゲストログイン")
        expect(response.body).to include("ログイン")
        expect(response.body).to include("新規ユーザー作成")
        expect(response.body).to include("お問い合わせ")
      end

      it "ログイン時にヘッダーに表示される項目がないこと" do
        expect(response.body).not_to include("アカウント")
        expect(response.body).not_to include("店舗登録")
        expect(response.body).not_to include("ログアウト")
      end

      it "ログインユーザーではないユーザー詳細画面にはユーザーの編集項目が含まれていないこと" do
        expect(response.body).not_to include(edit_user_path)
        expect(response.body).not_to include(edit_user_registration_path)
      end
    end
  end

  describe "GET /users/sign_in" do
    it "ログインページにアクセスできること" do
      get new_user_session_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /users/sign_up" do
    it "新規ユーザー作成ページにアクセスできること" do
      get new_user_registration_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /users/:id" do
    before { sign_in user }

    context "有効なパラメータを持つ場合" do
      it "ユーザーを更新し、ユーザーページにリダイレクトすること" do
        patch user_path(user), params: { user: { name: "New Name" } }
        user.reload
        expect(user.name).to eq("New Name")
        expect(response).to redirect_to(user_path(user))
        expect(flash[:notice]).to eq("ユーザー情報を更新しました!")
      end
    end

    context "有効なパラメータを持たない場合" do
      it "ユーザー情報を更新しないこと" do
        patch user_path(user), params: { user: { name: "Another Test User" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.name).to_not eq("Another Test User")
        expect(user.name).to eq("Test User")
        expect(response.body).to include("ユーザー名はすでに存在します")
      end
    end
  end
end
