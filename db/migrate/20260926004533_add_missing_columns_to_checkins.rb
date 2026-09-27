class AddMissingColumnsToCheckins < ActiveRecord::Migration[8.1]
  # CreateCheckins quedó aplicada creando solo la tabla vacía, así que aquí van sus columnas.
  # Con guardas, para que en una base nueva —donde CreateCheckins sí las crea— esto no haga nada.
  def change
    # Una llegada por persona: el índice único es el que impide dos registros de la misma llegada.
    unless column_exists?(:checkins, :participant_id)
      add_reference :checkins, :participant, type: :uuid, null: false, foreign_key: true, index: { unique: true }
    end
    unless column_exists?(:checkins, :recorded_by_id)
      add_reference :checkins, :recorded_by, type: :uuid, null: true, foreign_key: { to_table: :participants }
    end

    # Denormalizado: la llegada sobrevive aunque se borre la ficha de quien la tomó.
    add_column :checkins, :recorded_by_name, :string, null: false unless column_exists?(:checkins, :recorded_by_name)
    # Cuándo llegó, que no es cuándo se sincronizó: sin señal el dato viaja más tarde.
    add_column :checkins, :recorded_at, :datetime, null: false unless column_exists?(:checkins, :recorded_at)
    add_column :checkins, :source, :integer, null: false, default: 0 unless column_exists?(:checkins, :source)
    # Lo genera el dispositivo: si reenvía la cola al recuperar señal, no se duplica.
    add_column :checkins, :client_token, :string unless column_exists?(:checkins, :client_token)

    add_index :checkins, :client_token, unique: true unless index_name_exists?(:checkins, "index_checkins_on_client_token")
    add_index :checkins, :recorded_at unless index_name_exists?(:checkins, "index_checkins_on_recorded_at")
  end
end
