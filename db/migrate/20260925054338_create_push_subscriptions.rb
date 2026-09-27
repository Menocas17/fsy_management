class CreatePushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    # Una fila por dispositivo: la misma persona puede tener el teléfono y la computadora suscritos.
    create_table :push_subscriptions, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :endpoint, null: false
      t.string :p256dh_key, null: false
      t.string :auth_key, null: false
      t.string :device
      t.datetime :last_used_at

      t.timestamps
    end
    add_index :push_subscriptions, :endpoint, unique: true
  end
end
