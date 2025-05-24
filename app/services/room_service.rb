class RoomService
  def self.available_rooms(exclude_room_id: nil)
    rooms = Room.joins("LEFT JOIN patients ON patients.room_id = rooms.id")
                .group("rooms.id")
                .having("COUNT(patients.id) < rooms.capacity")

    rooms = rooms.where.not(id: exclude_room_id) if exclude_room_id
    rooms
  end

  def self.can_assign_patient?(room)
    return false unless room
    room.patients.count < room.capacity
  end

  def self.update_room_status(room)
    patient_count = room.patients.count

    new_status = if patient_count >= room.capacity && room.doctors.any?
                   :occupied
    elsif patient_count > 0 && room.doctors.empty?
                   :patient_only
    elsif patient_count == 0 && room.doctors.any?
                   :doctor_assigned
    else
                   :available
    end

    room.update_column(:room_status, Room.room_statuses[new_status])
  end

  def self.assign_patient_to_room(patient, room)
    return false unless can_assign_patient?(room)

    ActiveRecord::Base.transaction do
      # Remove patient from previous room if any
      if patient.room.present?
        old_room = patient.room
        patient.update!(room: nil)
        update_room_status(old_room)
      end

      # Assign to new room
      patient.update!(room: room)
      update_room_status(room)
      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def self.discharge_patient(patient)
    return false unless patient.room.present?

    ActiveRecord::Base.transaction do
      room = patient.room
      patient.update!(room: nil, condition: :discharged)
      update_room_status(room)
      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def self.room_availability_info(room)
    patient_count = room.patients.count
    {
      current_patients: patient_count,
      capacity: room.capacity,
      available_spots: room.capacity - patient_count,
      is_full: patient_count >= room.capacity,
      utilization_percentage: (patient_count.to_f / room.capacity * 100).round(1)
    }
  end
end
