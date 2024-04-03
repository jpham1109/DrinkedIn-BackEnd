# frozen_string_literal: true

class CreateFavorites < ActiveRecord::Migration[6.1]
  def change
    create_table :favorites do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :favorited_bar_id

      t.timestamps
    end
  end
end
