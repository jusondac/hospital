class Patient < ApplicationRecord
  belongs_to :room, optional: true

  validates :name, presence: true
  validates :gender, presence: true
  validates :age, presence: true, numericality: { greater_than: 0 }
  validates :condition, presence: true

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
end
