class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :produce
      t.string :binding
      t.string :page
      t.string :author
      t.string :paper
      t.string :gist
      t.string :edition
      t.string :title
      t.string :price
      t.string :isbn
      t.string :pubdate
      t.string :img
      t.string :format
      t.string :publisher
      t.timestamps
    end

    add_index :books, :isbn
  end
end
