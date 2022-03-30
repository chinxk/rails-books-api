class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|

      t.string :openid, null:false, unique:true
      t.string :nick_name
      t.text :avatar_url

      t.timestamps
    end
  end
end
