# Una alerta para unas pocas personas a la vez (los consejeros y auxiliares de un joven en enfermería): una
# sola fila compartida, como las de todos o por roles, en vez de una alerta por persona.
class AddRecipientIdsToAlerts < ActiveRecord::Migration[8.1]
  def change
    add_column :alerts, :recipient_ids, :uuid, array: true, null: false, default: []
    add_index :alerts, :recipient_ids, using: :gin
  end
end
