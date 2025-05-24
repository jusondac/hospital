class RoomDoctor < ApplicationRecord
  belongs_to :room
  belongs_to :doctor
  
  validates :room_id, uniqueness: { scope: :doctor_id }
end
