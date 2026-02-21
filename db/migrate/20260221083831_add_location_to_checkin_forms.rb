class AddLocationToCheckinForms < ActiveRecord::Migration[8.0]
  def change
    add_column :checkin_forms, :mode, :integer
    add_column :checkin_forms, :latitude, :decimal
    add_column :checkin_forms, :longitude, :decimal
    add_column :checkin_forms, :radius, :integer
  end
end
