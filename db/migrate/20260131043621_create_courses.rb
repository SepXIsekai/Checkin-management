class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :code
      t.string :name
      t.integer :year
      t.integer :semester

      t.timestamps
    end
  end
end
