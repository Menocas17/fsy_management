# El hotel: sus pasillos y los cuartos de cada uno, con cuántas camas tienen. El ordenamiento de cuartos
# (RoomPlanner) los recorre en este orden. participants.room sigue guardando el número del cuarto.
class CreateHallwaysAndRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :hallways, id: :uuid do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      # nil: lo decide el ordenamiento; M o H: el pasillo es de mujeres o de hombres siempre.
      t.integer :gender
      # Un pasillo largo lleva dos cuartos de consejeros, uno al inicio y otro al final.
      t.boolean :long, null: false, default: false
      t.timestamps
    end
    add_index :hallways, :name, unique: true

    create_table :rooms, id: :uuid do |t|
      t.references :hallway, type: :uuid, null: false, foreign_key: true
      t.string :number, null: false
      t.integer :position, null: false, default: 0
      t.integer :capacity, null: false, default: 4
      t.integer :purpose, null: false, default: 0
      t.timestamps
    end
    add_index :rooms, :number, unique: true
  end
end
