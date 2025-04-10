class AddLikesCountToWordbooks < ActiveRecord::Migration[7.1]
  def up
    add_column :wordbooks, :likes_count, :integer, null: false, default: 0

    # 既存のデータに対してカウントを更新
    Wordbook.find_each do |wordbook|
      Wordbook.update_counters(
        wordbook.id,
        likes_count: wordbook.likes.length
      )
    end
  end

  def down
    remove_column :wordbooks, :likes_count
  end
end
