class CreateRoomNurses < ActiveRecord::Migration[8.0]
  def change
    create_table :room_nurses do |t|
      t.references :room, null: false, foreign_key: true
      t.references :nurse, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :room_nurses, [:room_id, :nurse_id], unique: true
  end
end
