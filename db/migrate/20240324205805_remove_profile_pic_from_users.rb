# frozen_string_literal: true

class RemoveProfilePicFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :profile_pic, :string
  end
end
