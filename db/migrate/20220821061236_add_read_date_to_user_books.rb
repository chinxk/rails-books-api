class AddReadDateToUserBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :user_books, :read_date, :date
  end
end
