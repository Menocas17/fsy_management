class EnsureCheckinFlagOnLogisticsAreas < ActiveRecord::Migration[8.1]
  # Qué área de logística registra llegadas. Es una bandera y no el nombre del área, para que mañana
  # puedan mover el registro a otro comité sin tocar código.
  # Va con SQL directo a propósito: usar el modelo aquí depende del esquema que ya tenga cargado
  # la aplicación, y por eso el intento anterior quedó a medias.
  def up
    add_column :logistics_areas, :checkin, :boolean, null: false, default: false unless column_exists?(:logistics_areas, :checkin)
    execute "UPDATE logistics_areas SET checkin = TRUE WHERE name = 'Registro'"
  end

  def down
    remove_column :logistics_areas, :checkin if column_exists?(:logistics_areas, :checkin)
  end
end
