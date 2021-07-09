class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.integer :liker_id
      t.integer :liked_cocktail_id

      t.timestamps
    end
  end
end
