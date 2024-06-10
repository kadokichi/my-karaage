class AddNicesCountToReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :reviews, :nices_count, :integer, default: 0
  end
end
