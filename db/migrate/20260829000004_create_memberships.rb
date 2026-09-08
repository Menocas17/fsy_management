class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :associable, polymorphic: true, type: :uuid, null: false
      t.references :participant, type: :uuid, foreign_key: { to_table: :participants }, null: false
      t.integer :role, null: false
      t.integer :gender, null: false

      t.index [ :associable_type, :associable_id, :role, :gender ], unique: true, name: "idx_memberships_gender_uniqueness"

      t.timestamps
    end
  end
end
