class CreateAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :alerts, id: :uuid do |t|
      t.references :sender, type: :uuid, foreign_key: { to_table: :participants, on_delete: :nullify }
      t.string :sender_name, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.integer :audience, null: false, default: 0
      t.string :target_roles, array: true, null: false, default: []
      t.integer :priority, null: false, default: 0
      t.boolean :send_email, null: false, default: false
      t.integer :source, null: false, default: 0
      t.timestamps
    end

    add_index :alerts, :created_at
    add_index :alerts, :target_roles, using: :gin
  end
end
