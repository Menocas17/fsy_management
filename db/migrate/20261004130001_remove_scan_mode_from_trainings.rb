# El escaneo ya no se abre por fecha ni por capacitación: hay un solo registro activo, en AppSetting (ScanWindow).
class RemoveScanModeFromTrainings < ActiveRecord::Migration[8.1]
  def change
    remove_column :trainings, :scan_mode, :integer, default: 0, null: false
  end
end
