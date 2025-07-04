class Doctor < ApplicationRecord
  has_many :nurses
  # Many-to-many relationship with rooms
  has_many :room_doctors, dependent: :destroy
  has_many :rooms, through: :room_doctors

  validates :name, presence: true
  validates :gender, presence: true
  validates :specialization, presence: true

  # Define which attributes can be searched with Ransack
  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "id", "name", "specialization", "updated_at", "gender" ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def assign_nurse(nurse)
    # Ensure the nurse is female
    if nurse.gender == "female"
      nurses << nurse
      true
    else
      false
    end
  end
end
