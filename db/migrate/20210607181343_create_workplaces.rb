class CreateWorkplaces < ActiveRecord::Migration[6.1]
  def change
    create_table :workplaces do |t|
      t.belongs_to :bar, null: false, foreign_key: true
      t.references :bartender, references: :users, foreign_key: { to_table: :users }
      t.string :schedule

      t.timestamps
    end
  end
end
