class ChangeGistOnBooks < ActiveRecord::Migration[7.0]
  def change
    change_column :books, :gist, :text
 end
end
