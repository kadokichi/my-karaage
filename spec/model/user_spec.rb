require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { create(:user) }
  let(:another_user) { build(:another_user) }
  let(:shop) { create(:shop, user: user) }
  let(:review) { create(:review, user: user, shop: shop) }
  let!(:like) { create(:like, user: user, shop: shop) }
  let!(:nice) { create(:nice, user: user, review: review) }

  describe "validations" do
    it "有効な属性を持つこと" do
      expect(user).to be_valid
    end

    it "名前がないと無効であること" do
      user.name = nil
      expect(user).to_not be_valid
    end

    it "20文字以上の名前は無効であること" do
      user.name = "a" * 21
      expect(user).to_not be_valid
    end

    it "メールアドレスが空の場合無効であること" do
      user.email = nil
      expect(user).to_not be_valid
    end

    it "50文字以上のメールアドレスは無効であること" do
      user.email = "a" * 41 + "@example.com"
      expect(user).to_not be_valid
    end

    it "名前が重複している場合は無効であること" do
      another_user.name = user.name
      another_user.save
      expect(another_user.errors[:name]).to include("はすでに存在します")
    end

    it "メールアドレスが重複している場合は無効であること" do
      another_user.email = user.email
      another_user.save
      expect(another_user.errors[:email]).to include("はすでに存在します")
    end
  end

  describe "associations" do
    it { is_expected.to have_one_attached(:image) }
    it { is_expected.to have_many(:shops).dependent(:destroy) }
    it { is_expected.to have_many(:reviews) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:liked_shops).through(:likes).source(:shop) }
    it { is_expected.to have_many(:nices).dependent(:destroy) }
  end

  describe "methods" do
    describe "#user_image" do
      it "添付画像があれば添付画像を返すこと" do
        user.image.attach(io: File.open(Rails.root.join("spec/images/sample_user_image.png")),
                          filename: 'sample_image.png', content_type: 'image/png')
        expect(user.user_image).to eq(user.image)
      end

      it "画像が添付されていない場合、'default-user.jpg'を返すこと" do
        expect(user.user_image).to eq("default-user.jpg")
      end
    end

    describe ".guest" do
      it "ゲストユーザーが存在しない場合、作成すること" do
        expect { User.guest } .to change(User, :count).by(1)
      end

      it "ゲストユーザが存在する場合、既存のゲストユーザを返すこと" do
        guest = User.guest
        expect(User.guest).to eq(guest)
      end
    end
  end
end
