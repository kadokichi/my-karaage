class AddLikesCountToShops < ActiveRecord::Migration[7.0]
  def change
    add_column :shops, :likes_count, :integer, default: 0
  end
end
