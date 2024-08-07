require 'rails_helper'

RSpec.describe Nice, type: :model do
  let!(:user) { create(:user) }
  let!(:shop) { create(:shop, user: user) }
  let!(:review) { create(:review, user: user, shop: shop) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:review) }
  end

  describe "counter_culture" do
    it "いいね作成時にレビューのnices_countが増えること" do
      expect do
        create(:nice, user: user, review: review)
      end.to change { review.reload.nices_count }.by(1)
    end

    it "いいね削除時にレビューのnices_countが減ること" do
      nice = create(:nice, user: user, review: review)
      expect do
        nice.destroy
      end.to change { review.reload.nices_count }.by(-1)
    end
  end

  describe "validations" do
    it "有効な属性を持つ場合に有効であること" do
      nice = Nice.new(user: user, review: review)
      expect(nice).to be_valid
    end

    it "ユーザーがない場合は無効であること" do
      nice = Nice.new(user: nil, review: review)
      expect(nice).not_to be_valid
    end

    it "レビューがない場合は無効であること" do
      nice = Nice.new(user: user, review: nil)
      expect(nice).not_to be_valid
    end
  end
end
