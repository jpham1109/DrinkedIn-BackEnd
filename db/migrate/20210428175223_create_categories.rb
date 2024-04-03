# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :definition
      t.jsonb :popular_drinks, array: true, default: []

      t.timestamps
    end
  end
end
