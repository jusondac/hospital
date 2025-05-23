class Room < ApplicationRecord
  belongs_to :doctor, optional: true
  belongs_to :nurse, optional: true
  has_one :patient

  validates :room_number, presence: true, uniqueness: true
  validates :room_type, presence: true

  def available?
    patient.nil?
  end

  def assign_staff(doctor, nurse)
    if nurse.gender == "female"
      update(doctor: doctor, nurse: nurse)
      true
    else
      false
    end
  end
end
