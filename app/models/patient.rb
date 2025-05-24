class Patient < ApplicationRecord
  belongs_to :room, optional: true

  validates :name, presence: true
  validates :gender, presence: true
  validates :age, presence: true, numericality: { greater_than: 0 }
  validates :condition, presence: true

  # Update room status when patient assignment changes
  after_save :update_room_status, if: :saved_change_to_room_id?
  after_destroy :update_old_room_status

  def assigned_to_room?
    room.present?
  end

  def discharge!
    if room.present?
      # Clear the patient from the room, making it available
      update!(room: nil)
      true
    else
      false
    end
  end

  def recovered?
    room.nil?
  end

  # Define which attributes can be searched with Ransack
  def self.ransackable_attributes(auth_object = nil)
    [ "age", "condition", "created_at", "gender", "id", "name", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "room" ]
  end

  private

  def update_room_status
    # Update the new room's status if present
    room&.send(:update_room_status)

    # Update the old room's status if it changed
    if saved_change_to_room_id?
      old_room_id = saved_change_to_room_id[0]
      old_room = Room.find_by(id: old_room_id)
      old_room&.send(:update_room_status)
    end
  end

  def update_old_room_status
    # Update room status when patient is destroyed
    room&.send(:update_room_status)
  end
end
