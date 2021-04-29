class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :full_name
      t.string :username
      t.string :password_digest
      t.string :location
      t.boolean :bartender
      t.string :work_at
      t.string :instagram_account
      t.string :biography
      t.integer :insta_follower
      t.integer :insta_following
      t.string :profile_pic
      t.text :workplace_photos, array: true
      t.float :workplace_rating
      t.text :workplace_reviews, array: true 
      t.integer :workplace_ratings_total

      t.timestamps
    end
  end
end
