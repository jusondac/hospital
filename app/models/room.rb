class Room < ApplicationRecord
  belongs_to :doctor, optional: true
  belongs_to :nurse, optional: true
  has_one :patient

  # Enums for room_type and room_status
  enum :room_type, {
    general_ward: 0,
    private_room: 1,
    icu: 2,
    operating_room: 3,
    emergency_room: 4
  }

  enum :room_status, {
    available: 0,
    occupied: 1,
    patient_only: 2,
    doctor_assigned: 3
  }

  validates :room_number, presence: true, uniqueness: true
  validates :room_type, presence: true

  # Update room_status after any changes
  after_save :update_room_status
  after_touch :update_room_status

  def available?
    patient.nil? && doctor.nil?
  end

  def fully_occupied?
    patient.present? && doctor.present?
  end

  def assign_staff(doctor, nurse)
    if nurse.gender == "female"
      update(doctor: doctor, nurse: nurse)
      true
    else
      false
    end
  end

  def calculate_status
    if patient.present? && doctor.present?
      "occupied"
    elsif patient.present? && doctor.nil?
      "patient_only"
    elsif patient.nil? && doctor.present?
      "doctor_assigned"
    else
      "available"
    end
  end

  private

  def update_room_status
    status = calculate_status
    update_column(:room_status, status) if room_status != status
  end
end
