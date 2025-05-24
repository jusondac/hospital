class CreateRoomDoctors < ActiveRecord::Migration[8.0]
  def change
    create_table :room_doctors do |t|
      t.references :room, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :room_doctors, [:room_id, :doctor_id], unique: true
  end
end
