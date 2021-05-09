class AddDetailsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :workplace_id, :string
    add_column :users, :workplace_address, :string
  end
end
