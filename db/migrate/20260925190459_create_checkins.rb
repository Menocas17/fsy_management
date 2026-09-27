class CreateCheckins < ActiveRecord::Migration[8.1]
  def change
    create_table :checkins, id: :uuid do |t|
      t.references :participant, type: :uuid, null: false, foreign_key: true
      t.references :recorded_by, type: :uuid, null: true, foreign_key: { to_table: :participants }
      # Denormalizado: la llegada queda registrada aunque después se borre la ficha de quien la tomó.
      t.string :recorded_by_name, null: false
      # Cuándo llegó, que no es lo mismo que cuándo llegó el dato: sin señal se guarda y se sincroniza después.
      t.datetime :recorded_at, null: false
      t.integer :source, null: false, default: 0
      # Lo genera el dispositivo: si el mismo escaneo se reenvía al recuperar señal, no se duplica.
      t.string :client_token

      t.timestamps
    end

    # Una llegada por persona. Cuando se agreguen las comidas, este índice pasa a incluir el tipo.
    add_index :checkins, :participant_id, unique: true
    add_index :checkins, :client_token, unique: true
    add_index :checkins, :recorded_at
  end
end
