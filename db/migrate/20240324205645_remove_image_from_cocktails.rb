# frozen_string_literal: true

class RemoveImageFromCocktails < ActiveRecord::Migration[7.0]
  def change
    remove_column :cocktails, :image, :string
  end
end
