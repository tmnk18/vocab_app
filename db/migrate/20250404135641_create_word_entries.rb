class CreateWordEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :word_entries do |t|
      t.string :word
      t.text :meaning
      t.text :example_sentence
      t.references :wordbook, null: false, foreign_key: true

      t.timestamps
    end
  end
end
