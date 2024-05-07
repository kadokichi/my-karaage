class CreateShops < ActiveRecord::Migration[7.0]
  def change
    create_table :shops do |t|
      t.string :name
      t.string :address
      t.integer :price
      t.string :taste
      t.text :description
      t.string :product_name
      t.string :shop_url

      t.timestamps
    end
  end
end
