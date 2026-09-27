class CreateTrainings < ActiveRecord::Migration[8.1]
  def up
    # Las capacitaciones dejan de ser tres constantes en un initializer: agregar otra es llenar un formulario.
    create_table :trainings, id: :uuid do |t|
      t.string :name, null: false
      t.date :held_on, null: false
      t.string :location
      t.text :notes

      t.timestamps
    end
    add_index :trainings, :held_on, unique: true

    create_table :training_attendances, id: :uuid do |t|
      t.references :training, type: :uuid, null: false, foreign_key: true
      t.references :participant, type: :uuid, null: false, foreign_key: true
      t.references :recorded_by, type: :uuid, null: true, foreign_key: { to_table: :participants }
      # Denormalizado: la asistencia sobrevive aunque se borre la ficha de quien la marcó.
      t.string :recorded_by_name, null: false
      # Cuándo se marcó, que sin señal no es cuándo se sincronizó.
      t.datetime :recorded_at, null: false
      t.integer :source, null: false, default: 0
      # Lo genera el dispositivo: reenviar la cola no duplica.
      t.string :client_token

      t.timestamps
    end
    add_index :training_attendances, [ :training_id, :participant_id ], unique: true
    add_index :training_attendances, :client_token, unique: true

    # Se siembran las fechas que ya estaban configuradas, para no perderlas.
    names = [ "Primera capacitación", "Segunda capacitación", "Tercera capacitación" ]
    Array(Rails.configuration.x.training_dates).sort.each_with_index do |date, index|
      execute <<~SQL.squish
        INSERT INTO trainings (id, name, held_on, created_at, updated_at)
        VALUES (gen_random_uuid(), '#{names[index] || "Capacitación"}', '#{date.iso8601}', NOW(), NOW())
        ON CONFLICT (held_on) DO NOTHING
      SQL
    end
  end

  def down
    drop_table :training_attendances
    drop_table :trainings
  end
end
