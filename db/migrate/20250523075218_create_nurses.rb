class CreateNurses < ActiveRecord::Migration[8.0]
  def change
    create_table :nurses do |t|
      t.string :name
      t.string :gender
      t.string :specialization
      t.references :doctor, null: true, foreign_key: true

      t.timestamps
    end
  end
end
