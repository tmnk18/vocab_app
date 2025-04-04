class CreateWordbooks < ActiveRecord::Migration[7.1]
  def change
    create_table :wordbooks do |t|
      t.string :title
      t.text :description
      t.boolean :is_public
      t.references :folder, null: false, foreign_key: true

      t.timestamps
    end
  end
end
