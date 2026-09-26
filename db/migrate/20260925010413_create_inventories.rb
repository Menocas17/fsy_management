class CreateInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :inventories, id: :uuid do |t|
      t.string :name, null: false
      t.string :description
      t.string :color, null: false, default: "primary"
      t.string :icon, null: false, default: "package"
      # Prefijo de los códigos de sus artículos: MAT-0031, MED-0007.
      t.string :code_prefix, null: false

      t.timestamps
    end
    add_index :inventories, :name, unique: true
    add_index :inventories, :code_prefix, unique: true

    create_table :inventory_items, id: :uuid do |t|
      t.references :inventory, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :code, null: false
      t.string :unit, null: false, default: "u"
      t.integer :minimum, null: false, default: 0
      # Existencia actual: siempre la suma de los movimientos, que la mantienen al día.
      t.integer :quantity, null: false, default: 0
      t.string :location
      t.text :notes

      t.timestamps
    end
    add_index :inventory_items, :code, unique: true
    add_index :inventory_items, [ :inventory_id, :name ]

    create_table :inventory_movements, id: :uuid do |t|
      t.references :inventory_item, type: :uuid, null: false, foreign_key: true
      t.references :participant, type: :uuid, null: true, foreign_key: true
      # Denormalizado: la entrada del historial sobrevive aunque la ficha se borre.
      t.string :participant_name, null: false
      t.integer :delta, null: false
      t.integer :reason, null: false, default: 0
      t.integer :source, null: false, default: 0
      t.string :note

      t.timestamps
    end
    add_index :inventory_movements, [ :inventory_item_id, :created_at ]
  end
end
