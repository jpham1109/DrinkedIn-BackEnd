class CreateCocktails < ActiveRecord::Migration[6.1]
  def change
    create_table :cocktails do |t|
      t.string :name
      t.string :image
      t.string :description
      t.string :execution
      t.text :ingredients, array: true
      t.references :bartender, references: :user, foreign_key: { to_table: :users }
      t.belongs_to :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
