class UpdateRoomNurseAndDoctor < ActiveRecord::Migration[8.0]
  def change
    add_column :room_doctors, :start_date, :datetime
    add_column :room_doctors, :finish_date, :datetime
    add_column :room_doctors, :active, :boolean
    add_column :doctors, :active, :boolean

    add_column :room_nurses, :start_date, :datetime
    add_column :room_nurses, :finish_date, :datetime
    add_column :room_nurses, :active, :boolean
    add_column :nurses, :active, :boolean
  end
end
