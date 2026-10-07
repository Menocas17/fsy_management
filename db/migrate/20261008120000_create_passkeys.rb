class CreatePasskeys < ActiveRecord::Migration[8.1]
  def change
    # El identificador de la cuenta para WebAuthn (user handle): con él la passkey dice de quién es sin escribir el correo.
    add_column :users, :webauthn_id, :string
    add_index :users, :webauthn_id, unique: true

    create_table :passkeys, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :external_id, null: false
      t.text :public_key, null: false
      t.bigint :sign_count, null: false, default: 0
      t.string :name, null: false
      t.datetime :last_used_at
      t.timestamps
    end
    add_index :passkeys, :external_id, unique: true
  end
end
