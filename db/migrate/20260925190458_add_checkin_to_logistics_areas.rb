class AddCheckinToLogisticsAreas < ActiveRecord::Migration[8.1]
  # La bandera que dice qué área de logística registra llegadas. En una base nueva la crea esta
  # migración; en la que ya existía la terminó de aplicar EnsureCheckinFlagOnLogisticsAreas.
  def up
    return if column_exists?(:logistics_areas, :checkin)

    add_column :logistics_areas, :checkin, :boolean, null: false, default: false
    execute "UPDATE logistics_areas SET checkin = TRUE WHERE name = 'Registro'"
  end

  def down
    remove_column :logistics_areas, :checkin if column_exists?(:logistics_areas, :checkin)
  end
end
