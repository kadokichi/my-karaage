require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:contact) { create(:contact) }

  describe "validations" do
    it "有効な属性を持つこと" do
      expect(contact).to be_valid
    end

    it "名前がないと無効であること" do
      contact.name = nil
      expect(contact).to_not be_valid
      expect(contact.errors[:name]).to include("を入力してください")
    end

    it "20文字以上の名前は無効であること" do
      contact.name = "a" * 21
      expect(contact).to_not be_valid
      expect(contact.errors[:name]).to include("は20文字以内で入力してください")
    end

    it "メールアドレスがないと無効であること" do
      contact.email = nil
      expect(contact).to_not be_valid
      expect(contact.errors[:email]).to include("を入力してください")
    end

    it "件名がないと無効であること" do
      contact.subject = nil
      expect(contact).to_not be_valid
      expect(contact.errors[:subject]).to include("を入力してください")
    end

    it "50文字以上の件名は無効であること" do
      contact.subject = "a" * 51
      expect(contact).to_not be_valid
      expect(contact.errors[:subject]).to include("は50文字以内で入力してください")
    end

    it "お問い合わせの内容がないと無効であること" do
      contact.message = nil
      expect(contact).to_not be_valid
      expect(contact.errors[:message]).to include("を入力してください")
    end

    it "500文字以上のお問い合わせの内容は無効であること" do
      contact.message = "a" * 501
      expect(contact).to_not be_valid
      expect(contact.errors[:message]).to include("は500文字以内で入力してください")
    end
  end
end
