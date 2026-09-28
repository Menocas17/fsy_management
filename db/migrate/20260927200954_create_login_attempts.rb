class CreateLoginAttempts < ActiveRecord::Migration[8.1]
  def change
    # Cada intento de inicio de sesión, bueno o malo: lo que la pantalla «Accesos» muestra al superadmin.
    create_table :login_attempts, id: :uuid do |t|
      t.string :email_address, null: false
      t.references :user, type: :uuid, null: true, foreign_key: { on_delete: :nullify }
      t.integer :result, null: false, default: 0
      t.string :ip_address
      t.string :user_agent

      t.datetime :created_at, null: false
    end
    add_index :login_attempts, :created_at
  end
end
