class CreateAlertDismissals < ActiveRecord::Migration[8.1]
  def change
    # Las alertas son compartidas (una fila para todo su público): borrar una de tu campanita es solo tuyo.
    create_table :alert_dismissals, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, index: false, foreign_key: { on_delete: :cascade } # el índice único de abajo ya empieza por user_id
      t.references :alert, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :created_at, null: false
    end
    add_index :alert_dismissals, [ :user_id, :alert_id ], unique: true

    # «Limpiar todo»: lo anterior a este momento ya no aparece, sin una fila por alerta.
    add_column :users, :alerts_cleared_at, :datetime
  end
end
