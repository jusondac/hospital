class Room < ApplicationRecord
  # Many-to-many relationships
  has_many :room_doctors, dependent: :destroy
  has_many :doctors, through: :room_doctors
  has_many :room_nurses, dependent: :destroy
  has_many :nurses, through: :room_nurses
  has_many :patients

  scope :is_available, -> {
    left_joins(:patients)
      .group("rooms.id")
      .having("COUNT(patients.id) < rooms.capacity")
  }

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
  validates :capacity, presence: true, numericality: { greater_than: 0, only_integer: true }

  # Update room_status after any changes
  after_save :update_room_status
  after_touch :update_room_status

  def assign_staff(doctors_list, nurses_list)
    # Clear existing associations
    self.doctors.clear
    self.nurses.clear
    
    # Add new doctors
    doctors_list.each do |doctor|
      self.doctors << doctor unless self.doctors.include?(doctor)
    end
    
    # Add new nurses (ensure they are female)
    nurses_list.each do |nurse|
      if nurse.gender == "female"
        self.nurses << nurse unless self.nurses.include?(nurse)
      end
    end
    
    save
  end

  def is_available?
    patients.count < capacity
  end

  def is_full?
    patients.count >= capacity
  end

  def available_spots
    capacity - patients.count
  end

  def utilization_percentage
    (patients.count.to_f / capacity * 100).round(1)
  end

  def calculate_status
    patient_count = patients.count

    if patient_count >= capacity && doctors.any?
      "occupied"
    elsif patient_count > 0 && doctors.empty?
      "patient_only"
    elsif patient_count == 0 && doctors.any?
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
