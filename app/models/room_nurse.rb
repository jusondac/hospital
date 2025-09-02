class RoomNurse < ApplicationRecord
  belongs_to :room
  belongs_to :nurse

  validates :room_id, uniqueness: { scope: :nurse_id }

  # Scopes for filtering active/inactive nurses
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
