class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :wordbook, null: false, foreign_key: true

      t.timestamps
    end

    add_index :likes, [:user_id, :wordbook_id], unique: true  # ←同じユーザーが同じ単語帳に複数いいねできない
  end
end