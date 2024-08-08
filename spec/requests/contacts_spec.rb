require 'rails_helper'

RSpec.describe "Contacts", type: :request do
  describe "GET /new" do
    it "お問い合わせ画面にアクセスできること" do
      get new_contact_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    let(:contact) { create(:contact) }
    let(:destination_address) { ENV['MAIL_ADDRESS'] }
    before do
      get new_contact_path
    end

    context "有効なパラメーターを持つ場合" do
      it "お問い合わせが作成でき、お問い合わせ完了画面に遷移すること" do
        contact_params = attributes_for(:contact)
        post contacts_path, params: { contact: contact_params }
        expect(response).to redirect_to(done_contacts_path)
        follow_redirect!
        expect(Contact.count).to eq(1)
        expect(response.body).to include("お問い合わせありがとうございました")
      end

      it "お問い合わせメールが送信できていること" do
        contact_params = attributes_for(:contact)
        post contacts_path, params: { contact: contact_params }
        expect(ActionMailer::Base.deliveries.count).to eq(1)

        sendmail = ActionMailer::Base.deliveries.last
        body = sendmail.body.encoded

        expect(sendmail.to).to include(destination_address)
        expect(body).to include(contact.name)
        expect(body).to include(contact.email)
        expect(body).to include(contact.subject)
        expect(body).to include(contact.message)
      end
    end

    context "有効なパラメーターを持たない場合" do
      it "お問い合わせが作成できずエラーメッセージが含まれること" do
        contact_params = attributes_for(:contact, name: nil)
        post contacts_path, params: { contact: contact_params }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Contact.count).to eq(0)
        expect(response.body).to include("お名前を入力してください")
      end
    end
  end

  describe "GET /done" do
    it "お問い合わせ完了画面にアクセスできること" do
      get done_contacts_path
      expect(response).to have_http_status(:success)
    end
  end
end
