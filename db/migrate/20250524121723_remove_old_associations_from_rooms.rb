class RemoveOldAssociationsFromRooms < ActiveRecord::Migration[8.0]
  def change
    # First, migrate existing data to the new join tables
    # This will be done in the up method to preserve data
    
    remove_foreign_key :rooms, :doctors
    remove_foreign_key :rooms, :nurses
    remove_column :rooms, :doctor_id, :integer
    remove_column :rooms, :nurse_id, :integer
  end
  
  def up
    # Migrate existing room-doctor associations
    Room.where.not(doctor_id: nil).find_each do |room|
      RoomDoctor.create!(room: room, doctor_id: room.doctor_id)
    end
    
    # Migrate existing room-nurse associations  
    Room.where.not(nurse_id: nil).find_each do |room|
      RoomNurse.create!(room: room, nurse_id: room.nurse_id)
    end
    
    # Remove the old columns
    remove_foreign_key :rooms, :doctors
    remove_foreign_key :rooms, :nurses
    remove_column :rooms, :doctor_id, :integer
    remove_column :rooms, :nurse_id, :integer
  end
  
  def down
    # Add back the old columns
    add_column :rooms, :doctor_id, :integer
    add_column :rooms, :nurse_id, :integer
    add_foreign_key :rooms, :doctors
    add_foreign_key :rooms, :nurses
    
    # Migrate data back (take the first association for each room)
    RoomDoctor.find_each do |rd|
      rd.room.update_column(:doctor_id, rd.doctor_id) if rd.room.doctor_id.nil?
    end
    
    RoomNurse.find_each do |rn|
      rn.room.update_column(:nurse_id, rn.nurse_id) if rn.room.nurse_id.nil?
    end
  end
end
