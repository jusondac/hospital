class UpdatePatients < ActiveRecord::Migration[8.0]
  def change
    add_column :patients, :blood_type, :string
    add_column :patients, :admission_date, :date
    add_column :patients, :diagnosis, :string
  end
end
