class CreateCheckinForms < ActiveRecord::Migration[8.0]
  def change
    create_table :checkin_forms do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title
      t.string :qr_token
      t.datetime :expires_at
      t.boolean :active

      t.timestamps
    end
    add_index :checkin_forms, :qr_token, unique: true
  end
end
