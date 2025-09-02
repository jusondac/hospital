class AddIndexesToRoomsForPerformance < ActiveRecord::Migration[8.0]
  def change
    # Add indexes for common queries in rooms controller
    add_index :rooms, :room_type
    add_index :rooms, :room_status
    add_index :rooms, [ :room_type, :room_status ]
    add_index :rooms, :room_number, unique: true
    add_column :patients, :discharge_date, :datetime
  end
end
