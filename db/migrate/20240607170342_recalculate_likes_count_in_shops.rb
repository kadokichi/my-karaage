class RecalculateLikesCountInShops < ActiveRecord::Migration[7.0]
  def up
    Shop.includes(:likes).find_each do |shop|
      shop.update(likes_count: shop.likes.count)
    end
  end
end
