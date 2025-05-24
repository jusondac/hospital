class Nurse < ApplicationRecord
  belongs_to :doctor, optional: true
  # Many-to-many relationship with rooms
  has_many :room_nurses, dependent: :destroy
  has_many :rooms, through: :room_nurses

  validates :name, presence: true
  validates :gender, presence: true, inclusion: { in: [ "female" ], message: "must be female" }
  validates :specialization, presence: true

  scope :available, -> { where(doctor_id: nil) }

  # Define which attributes can be searched with Ransack
  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "id", "name", "specialization", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
