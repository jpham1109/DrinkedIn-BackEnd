class DropInstaColumnsFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :insta_follower, :integer
    remove_column :users, :insta_following, :integer

    remove_column :bars, :rating, :float
    remove_column :bars, :total_ratings, :integer
    remove_column :bars, :photos, :text, array: true
    remove_column :bars, :reviews, :text, array: true
  end
end
