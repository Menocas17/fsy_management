class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.references :actor, type: :uuid, foreign_key: { to_table: :participants, on_delete: :nullify }
      t.string :actor_name, null: false
      t.string :action, null: false
      t.integer :category, null: false
      t.string :summary, null: false
      t.string :target_type
      t.uuid :target_id
      t.string :target_name

      t.timestamps
    end

    add_index :audit_logs, :category
    add_index :audit_logs, :created_at
    add_index :audit_logs, [ :target_type, :target_id ]
  end
end
