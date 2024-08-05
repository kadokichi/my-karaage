require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:user) { create(:user) }
  let(:shop) { create(:shop, user: user) }
  let(:review) { create(:review, user: user, shop: shop) }
  let(:nice) { create(:nice, review: review, user: user) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:shop) }
    it { is_expected.to have_many(:nices).dependent(:destroy) }
  end

  describe "validations" do
    it "有効な属性を持つこと" do
      expect(review).to be_valid
    end

    it "お店の評価がないと無効であること" do
      review.score = nil
      expect(review).not_to be_valid
      expect(review.errors[:score]).to include("を入力してください")
    end

    it "口コミがないと無効であること" do
      review.content = nil
      expect(review).not_to be_valid
      expect(review.errors[:content]).to include("を入力してください")
    end

    it "150文字以上の口コミは無効であること" do
      review.content = "a" * 151
      expect(review).not_to be_valid
      expect(review.errors[:content]).to include("は150文字以内で入力してください")
    end

    it "ユーザがすでにショップをレビューしている場合は無効であること" do
      duplicate_review = review.dup
      duplicate_review.score = 4
      duplicate_review.content = "Good place!"

      expect(duplicate_review).not_to be_valid
      expect(duplicate_review.errors[:user_id]).to include("はすでに存在します")
    end
  end

  describe "#niced_by?" do
    it "レビューがユーザーに「いいね」された場合、trueを返すこと" do
      nice
      expect(review.niced_by?(user)).to be true
    end

    it "レビューがユーザーによって「いいね」されていない場合、falseを返す" do
      expect(review.niced_by?(user)).to be false
    end

    it "ユーザーがnilの場合はfalseを返すこと" do
      expect(review.niced_by?(nil)).to be false
    end
  end

  describe "#update_nices_count" do
    let!(:user) { create(:user) }
    let!(:another_user) { create(:another_user) }
    let!(:shop) { create(:shop, user: user) }
    let!(:review) { create(:review, user: user, shop: shop) }
    let!(:nice) { create(:nice, review: review, user: another_user) }

    it "nices_countを正しく更新すること" do
      create(:nice, review: review, user: user)
      review.update_nices_count
      expect(review.nices_count).to eq(2)
    end

    it "レビューの「いいね」がない場合、nices_countを0に設定する" do
      review.nices.destroy_all
      review.update_nices_count
      expect(review.nices_count).to eq(0)
    end
  end
end
