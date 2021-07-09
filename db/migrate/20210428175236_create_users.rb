class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :full_name
      t.string :username
      t.string :password_digest
      t.string :location
      t.boolean :bartender
      t.string :instagram_account
      t.string :biography
      t.integer :insta_follower
      t.integer :insta_following
      t.text :profile_pic

      t.timestamps
    end
  end
end
