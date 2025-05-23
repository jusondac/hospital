class CreateDoctors < ActiveRecord::Migration[8.0]
  def change
    create_table :doctors do |t|
      t.string :name
      t.string :gender
      t.string :specialization

      t.timestamps
    end
  end
end
