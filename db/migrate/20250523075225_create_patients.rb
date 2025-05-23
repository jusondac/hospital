class CreatePatients < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      t.string :name
      t.string :gender
      t.integer :age
      t.string :condition
      t.references :room, null: true, foreign_key: true

      t.timestamps
    end
  end
end
