class AddRoomStatusToRooms < ActiveRecord::Migration[8.0]
  def change
    add_column :rooms, :room_status, :string
  end
end
