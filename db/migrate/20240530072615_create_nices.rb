class CreateNices < ActiveRecord::Migration[7.0]
  def change
    create_table :nices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :review, null: false, foreign_key: true

      t.timestamps
    end
  end
end
