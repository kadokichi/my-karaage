require 'rails_helper'

RSpec.describe "Contacts", type: :system do
  describe "お問い合わせの作成" do
    context "確認画面への遷移" do
      let(:contact) { create(:contact) }
      before do
        visit new_contact_path
      end

      it "正しいパラメータを入力した場合、確認画面が表示されること" do
        fill_in "お名前", with: contact.name
        fill_in "メールアドレス", with: contact.email
        fill_in "件名", with: contact.subject
        fill_in "お問い合わせの内容", with: contact.message
        click_button "確認"

        expect(current_path).to eq(confirm_contacts_path)
        expect(page).to have_content(contact.name)
        expect(page).to have_content(contact.email)
        expect(page).to have_content(contact.subject)
        expect(page).to have_content(contact.message)
      end

      it "入力項目に不備がある場合は確認画面へ遷移ができず、エラーメッセージが表示されること" do
        fill_in "お名前", with: contact.name
        fill_in "メールアドレス", with: contact.email
        fill_in "件名", with: ""
        fill_in "お問い合わせの内容", with: contact.message
        click_button "確認"

        expect(page).to have_content("件名を入力してください")
      end

      it "キャンセルをクリックすると、トップページに遷移されること" do
        click_on "キャンセル"

        expect(current_path).to eq(root_path)
      end
    end
  end

  context "確認画面の操作" do
    let(:contact) { create(:contact) }
    before do
      visit new_contact_path
      fill_in "お名前", with: contact.name
      fill_in "メールアドレス", with: contact.email
      fill_in "件名", with: contact.subject
      fill_in "お問い合わせの内容", with: contact.message
      click_button "確認"
    end

    it "確認画面の戻るボタンをクリックすると、データが入力された状態のお問い合わせ作成画面に戻ること" do
      click_button "戻る"

      expect(current_path).to eq(back_contacts_path)
      expect(find_field('contact[name]').value).to eq(contact.name)
      expect(find_field('contact[email]').value).to eq(contact.email)
      expect(find_field('contact[subject]').value).to eq(contact.subject)
      expect(find_field('contact[message]').value).to eq(contact.message)
    end

    it "確認画面の送信ボタンをクリックすると、お問い合わせが送信されお問い合わせ完了画面に遷移すること" do
      click_button "送信"

      expect(current_path).to eq(done_contacts_path)
      expect(page).to have_content("お問い合わせありがとうございました")
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
