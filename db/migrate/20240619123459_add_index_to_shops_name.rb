class AddIndexToShopsName < ActiveRecord::Migration[7.0]
  def change
    add_index :shops, :name, unique: true
  end
end
