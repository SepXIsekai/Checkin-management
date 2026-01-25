class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :student_id, :string
    add_column :users, :role, :integer
  end
end
