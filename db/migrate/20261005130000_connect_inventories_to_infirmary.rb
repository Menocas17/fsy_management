# Enfermería toma sus medicamentos del inventario: un inventario marcado «de enfermería» ofrece sus artículos al
# anotar un medicamento, y cada dosis dada es una salida de ese inventario atada a la nota que la registró. Si la
# nota desaparece (se borra la ficha del joven), la salida se queda: la existencia no puede cambiar hacia atrás.
class ConnectInventoriesToInfirmary < ActiveRecord::Migration[8.1]
  def change
    add_column :inventories, :infirmary, :boolean, null: false, default: false
    add_reference :inventory_movements, :infirmary_note, type: :uuid, foreign_key: { on_delete: :nullify }
  end
end
