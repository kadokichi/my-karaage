require 'rails_helper'

RSpec.describe Shop, type: :model do
  describe "associations" do
    let(:user) { create(:user) }
    let(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, user: user, shop: shop) }
    let!(:like) { create(:like, user: user, shop: shop) }

    it { is_expected.to have_one_attached(:image) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
  end

  describe "validations" do
    let(:shop) { build(:shop, user: user) }
    let!(:user) { create(:user) }

    it "有効な属性を持つこと" do
      expect(shop).to be_valid
    end

    it "ショップ名がないと無効であること" do
      shop.name = nil
      expect(shop).not_to be_valid
      expect(shop.errors[:name]).to include("を入力してください")
    end

    it "30文字以上の店舗名は無効であること" do
      shop.name = 'a' * 31
      expect(shop).not_to be_valid
      expect(shop.errors[:name]).to include("は30文字以内で入力してください")
    end

    it "店舗前が重複している場合は無効であること" do
      create(:shop, name: shop.name, user: user)
      expect(shop).not_to be_valid
      expect(shop.errors[:name]).to include("はすでに存在します")
    end

    it "店舗の住所が空の場合無効であること" do
      shop.address = nil
      expect(shop).not_to be_valid
      expect(shop.errors[:address]).to include("を入力してください")
    end

    it "50文字以上の住所は無効であること" do
      shop.address = 'a' * 51
      expect(shop).not_to be_valid
      expect(shop.errors[:address]).to include("は50文字以内で入力してください")
    end

    it "価格が空の場合は無効であること" do
      shop.price = nil
      expect(shop).not_to be_valid
      expect(shop.errors[:price]).to include("を入力してください")
    end

    it "価格が整数以外の場合は無効であること" do
      shop.price = "10.5"
      expect(shop).not_to be_valid
      expect(shop.errors[:price]).to include("は整数で入力してください")
    end

    it "価格が2文字以下の場合は無効であること" do
      shop.price = 9
      expect(shop).not_to be_valid
      expect(shop.errors[:price]).to include("は2文字以上で入力してください")
    end

    it "価格が5文字以上の場合は無効であること" do
      shop.price = 100000
      expect(shop).not_to be_valid
      expect(shop.errors[:price]).to include("は5文字以内で入力してください")
    end

    it "味の系統が空の場合は無効であること" do
      shop.taste = nil
      expect(shop).not_to be_valid
      expect(shop.errors[:taste]).to include("を入力してください")
    end

    it "お店のPRが空の場合は無効であること" do
      shop.description = nil
      expect(shop).not_to be_valid
      expect(shop.errors[:description]).to include("を入力してください")
    end

    it "お店のPRが150文字以上の場合は無効であること" do
      shop.description = 'a' * 151
      expect(shop).not_to be_valid
      expect(shop.errors[:description]).to include("は150文字以内で入力してください")
    end

    it "商品名が空の場合は無効であること" do
      shop.product_name = nil
      expect(shop).not_to be_valid
      expect(shop.errors[:product_name]).to include("を入力してください")
    end

    it "商品名が20文字以上の場合は無効であること" do
      shop.product_name = 'a' * 21
      expect(shop).not_to be_valid
      expect(shop.errors[:product_name]).to include("は20文字以内で入力してください")
    end
  end

  describe "callbacks" do
    let!(:user) { create(:user) }
    let(:shop) { create(:shop, user: user) }

    it "検証後に住所をジオコード化" do
      shop = build(:shop, user: user)
      expect(shop).to receive(:geocode)
      shop.valid?
    end
  end

  describe "methods" do
    let!(:user) { create(:user) }
    let!(:another_user) { create(:another_user) }
    let(:guest_user) { build(:guest_user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:like) { create(:like, shop: shop, user: another_user) }

    describe "#shop_image" do
      it "添付画像があれば添付画像を返すこと" do
        shop.image.attach(io: File.open(Rails.root.join("spec/images/sample_shop_image.jpeg")),
                          filename: "sample_image.jpeg", content_type: "image/jpeg")
        expect(shop.shop_image).to eq(shop.image)
      end

      it "画像が添付されていない場合、'default-shop.jpg'を返すこと" do
        expect(shop.shop_image).to eq("default-shop.jpg")
      end
    end

    describe "#update_likes_count" do
      it "likes_countカラムを「いいね」の数で更新すること" do
        create(:like, shop: shop, user: user)
        shop.update_likes_count
        expect(shop.likes_count).to eq(2)
      end
    end

    describe "#liked?" do
      context "ユーザーがショップに「いいね」をした場合" do
        it 'returns true' do
          expect(shop.liked?(another_user)).to be true
        end
      end

      context "ユーザーがショップに「いいね」をしていない場合" do
        it 'returns false' do
          expect(shop.liked?(guest_user)).to be false
        end
      end

      context "ユーザーが作成されていないしていない場合" do
        it 'returns false' do
          expect(shop.liked?(nil)).to be false
        end
      end
    end
  end
end
