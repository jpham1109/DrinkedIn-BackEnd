class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :full_name
      t.string :username
      t.string :password_digest
      t.string :location
      t.boolean :bartender
      t.string :work_at
      t.string :instagram_account

      t.timestamps
    end
  end
end
