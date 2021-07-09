class CreateBars < ActiveRecord::Migration[6.1]
  def change
    create_table :bars do |t|
      t.string :name
      t.string :address
      t.float :rating
      t.integer :total_ratings
      t.text :photos, array:true 
      t.text :reviews, array:true 

      t.timestamps
    end
  end
end
