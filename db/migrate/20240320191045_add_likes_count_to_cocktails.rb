# frozen_string_literal: true

class AddLikesCountToCocktails < ActiveRecord::Migration[7.0]
  def change
    add_column :cocktails, :likes_count, :integer, default: 0, null: false
  end
end
