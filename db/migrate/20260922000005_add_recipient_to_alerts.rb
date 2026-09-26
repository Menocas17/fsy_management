class AddRecipientToAlerts < ActiveRecord::Migration[8.1]
  def change
    add_reference :alerts, :recipient, type: :uuid, foreign_key: { to_table: :participants, on_delete: :cascade }
  end
end
