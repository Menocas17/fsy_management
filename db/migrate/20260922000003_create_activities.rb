class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities, id: :uuid do |t|
      t.string :title, null: false
      t.text :description
      t.integer :category, null: false, default: 0
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :location
      t.integer :audience, null: false, default: 0
      t.string :target_roles, array: true, null: false, default: []
      t.text :logistics_notes
      t.text :counselors_notes
      t.text :youth_notes
      t.timestamps
    end
    add_index :activities, :starts_at

    create_table :activity_responsibles, id: :uuid do |t|
      t.references :activity, type: :uuid, null: false, foreign_key: true
      t.references :participant, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
    add_index :activity_responsibles, [ :activity_id, :participant_id ], unique: true

    add_reference :alerts, :activity, type: :uuid, foreign_key: { on_delete: :nullify }
  end
end
