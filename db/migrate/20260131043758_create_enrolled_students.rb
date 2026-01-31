class CreateEnrolledStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :enrolled_students do |t|
      t.references :course, null: false, foreign_key: true
      t.string :student_id

      t.timestamps
    end
  end
end
