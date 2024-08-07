require 'rails_helper'

RSpec.describe Like, type: :model do
  let!(:user) { create(:user) }
  let!(:shop) { create(:shop, user: user) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:shop) }
  end

  describe "counter_culture" do
    it "いいね作成時に店舗のlikes_countが増えること" do
      expect do
        create(:like, user: user, shop: shop)
      end.to change { shop.reload.likes_count }.by(1)
    end

    it "いいね削除時に店舗のlikes_countが減ること" do
      like = create(:like, user: user, shop: shop)
      expect do
        like.destroy
      end.to change { shop.reload.likes_count }.by(-1)
    end
  end

  describe "validations" do
    it "有効な属性を持つ場合に有効であること" do
      like = Like.new(user: user, shop: shop)
      expect(like).to be_valid
    end

    it "ユーザーがない場合は無効であること" do
      like = Like.new(user: nil, shop: shop)
      expect(like).not_to be_valid
    end

    it "店舗がない場合は無効であること" do
      like = Like.new(user: user, shop: nil)
      expect(like).not_to be_valid
    end
  end
end
