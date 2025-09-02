class RoomDoctor < ApplicationRecord
  belongs_to :room
  belongs_to :doctor

  validates :room_id, uniqueness: { scope: :doctor_id }

  # Scopes for filtering active/inactive doctors
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Set default values
  before_create :set_defaults

  private

  def set_defaults
    self.active = true if active.nil?
    self.start_date = DateTime.current if start_date.nil?
  end
end
