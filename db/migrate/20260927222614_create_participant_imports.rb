class CreateParticipantImports < ActiveRecord::Migration[8.1]
  def change
    # Cada carga masiva queda guardada con su informe, para volver a verlo cuando se quiera.
    create_table :participant_imports, id: :uuid do |t|
      t.string :filename, null: false
      t.references :uploaded_by, type: :uuid, foreign_key: { to_table: :participants, on_delete: :nullify }
      t.string :uploaded_by_name, null: false
      t.timestamps
    end

    # Una fila por persona del archivo. Las limpias entran directo (imported); las que tienen un problema
    # o un aviso quedan en espera (pending), fuera de la base, hasta que alguien las corrige y aprueba o
    # las descarta. values guarda lo que trajo el archivo; es lo que se edita.
    create_table :participant_import_rows, id: :uuid do |t|
      t.references :participant_import, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.integer :row_number, null: false
      t.jsonb :values, null: false, default: {}
      t.integer :status, null: false, default: 0
      t.jsonb :issues, null: false, default: []
      t.references :participant, type: :uuid, foreign_key: { on_delete: :nullify }
      t.string :resolved_by_name
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :participant_import_rows, [ :participant_import_id, :status ]
  end
end
