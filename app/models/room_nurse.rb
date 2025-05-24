class RoomNurse < ApplicationRecord
  belongs_to :room
  belongs_to :nurse
  
  validates :room_id, uniqueness: { scope: :nurse_id }
end
