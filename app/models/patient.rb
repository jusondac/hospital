class Patient < ApplicationRecord
  belongs_to :room, optional: true

  # Define enum for condition (integer values)
  enum :condition, {
    stable: 0,
    critical: 1,
    recovering: 2,
    discharged: 3
  }

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

  def recovered?
    room.nil?
  end

  private

  def update_room_status
    RoomService.update_room_status(room) if room.present?
    RoomService.update_room_status(Room.find(room_id_was)) if room_id_was.present?
  end

  def update_old_room_status
    RoomService.update_room_status(Room.find(room_id)) if room_id.present?
  end

  public

  # Define which attributes can be searched with Ransack
  def self.ransackable_attributes(auth_object = nil)
    [ "age", "condition", "created_at", "gender", "id", "name", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "room" ]
  end

  private

  # def update_room_status
  #   # Update the new room's status if present
  #   room&.send(:update_room_status)

  #   # Update the old room's status if it changed
  #   if saved_change_to_room_id?
  #     old_room_id = saved_change_to_room_id[0]
  #     old_room = Room.find_by(id: old_room_id)
  #     old_room&.send(:update_room_status)
  #   end
  # end

  # def update_old_room_status
  #   # Update room status when patient is destroyed
  #   room&.send(:update_room_status)
  # end
end
