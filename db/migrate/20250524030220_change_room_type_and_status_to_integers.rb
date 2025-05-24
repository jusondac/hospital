class ChangeRoomTypeAndStatusToIntegers < ActiveRecord::Migration[8.0]
  def up
    # Add temporary columns
    add_column :rooms, :room_type_temp, :integer
    add_column :rooms, :room_status_temp, :integer

    # Convert existing data using direct SQL to avoid model conflicts
    execute <<-SQL
      UPDATE rooms SET#{' '}
        room_type_temp = CASE room_type
          WHEN 'General Ward' THEN 0
          WHEN 'Private Room' THEN 1
          WHEN 'ICU' THEN 2
          WHEN 'Operating Room' THEN 3
          WHEN 'Emergency Room' THEN 4
          ELSE 0
        END,
        room_status_temp = CASE room_status
          WHEN 'available' THEN 0
          WHEN 'occupied' THEN 1
          WHEN 'patient_only' THEN 2
          WHEN 'doctor_assigned' THEN 3
          ELSE 0
        END
    SQL

    # Drop old columns
    remove_column :rooms, :room_type
    remove_column :rooms, :room_status

    # Rename temp columns
    rename_column :rooms, :room_type_temp, :room_type
    rename_column :rooms, :room_status_temp, :room_status
  end

class ChangeRoomTypeAndStatusToIntegers < ActiveRecord::Migration[8.0]
  def up
    # Add temporary columns
    add_column :rooms, :room_type_temp, :integer
    add_column :rooms, :room_status_temp, :integer

    # Convert existing data using direct SQL to avoid model conflicts
    execute <<-SQL
      UPDATE rooms SET#{' '}
        room_type_temp = CASE room_type
          WHEN 'General Ward' THEN 0
          WHEN 'Private Room' THEN 1
          WHEN 'ICU' THEN 2
          WHEN 'Operating Room' THEN 3
          WHEN 'Emergency Room' THEN 4
          ELSE 0
        END,
        room_status_temp = CASE room_status
          WHEN 'available' THEN 0
          WHEN 'occupied' THEN 1
          WHEN 'patient_only' THEN 2
          WHEN 'doctor_assigned' THEN 3
          ELSE 0
        END
    SQL

    # Drop old columns
    remove_column :rooms, :room_type
    remove_column :rooms, :room_status

    # Rename temp columns
    rename_column :rooms, :room_type_temp, :room_type
    rename_column :rooms, :room_status_temp, :room_status
  end

  def down
    # Add temporary string columns
    add_column :rooms, :room_type_temp, :string
    add_column :rooms, :room_status_temp, :string

    # Convert back to strings using direct SQL
    execute <<-SQL
      UPDATE rooms SET#{' '}
        room_type_temp = CASE room_type
          WHEN 0 THEN 'General Ward'
          WHEN 1 THEN 'Private Room'
          WHEN 2 THEN 'ICU'
          WHEN 3 THEN 'Operating Room'
          WHEN 4 THEN 'Emergency Room'
          ELSE 'General Ward'
        END,
        room_status_temp = CASE room_status
          WHEN 0 THEN 'available'
          WHEN 1 THEN 'occupied'
          WHEN 2 THEN 'patient_only'
          WHEN 3 THEN 'doctor_assigned'
          ELSE 'available'
        END
    SQL

    # Drop integer columns
    remove_column :rooms, :room_type
    remove_column :rooms, :room_status

    # Rename temp columns back
    rename_column :rooms, :room_type_temp, :room_type
    rename_column :rooms, :room_status_temp, :room_status
  end
end
end
