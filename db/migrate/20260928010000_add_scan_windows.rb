class AddScanWindows < ActiveRecord::Migration[8.1]
  def change
    # Cuándo se puede escanear cada capacitación: solo su día (automático), siempre, o nunca.
    add_column :trainings, :scan_mode, :integer, null: false, default: 0

    # Ajustes del sistema que no pertenecen a ningún registro; hoy, la ventana de la llegada al FSY.
    create_table :app_settings, id: :uuid do |t|
      t.string :key, null: false
      t.string :value

      t.timestamps
    end
    add_index :app_settings, :key, unique: true
  end
end
