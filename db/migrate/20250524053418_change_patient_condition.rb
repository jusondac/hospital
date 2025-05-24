class ChangePatientCondition < ActiveRecord::Migration[8.0]
  def change
    add_column :patients, :condition_temp, :integer
    Patient.reset_column_information
    Patient.find_each do |patient|
      condition = case patient.read_attribute(:condition)
      when 'Stable' then 0
      when 'Critical' then 1
      when 'Recovering' then 2
      when 'Discharged' then 3
      else 0 # Default to stable for unknown conditions
      end
      patient.update(condition_temp: condition)
    end

    remove_column :patients, :condition
    rename_column :patients, :condition_temp, :condition
  end
end
