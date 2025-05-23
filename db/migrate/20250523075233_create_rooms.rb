class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :room_number
      t.string :room_type
      t.references :doctor, null: true, foreign_key: true
      t.references :nurse, null: true, foreign_key: true

      t.timestamps
    end
  end
end
