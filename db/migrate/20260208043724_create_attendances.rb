class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :checkin_form, null: false, foreign_key: true
      t.string :student_id
      t.string :name
      t.datetime :checked_at

      t.timestamps
    end
    add_index :attendances, [ :checkin_form_id, :student_id ], unique: true
  end
end
