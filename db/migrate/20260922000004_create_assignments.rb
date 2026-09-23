class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments, id: :uuid do |t|
      t.references :participant, type: :uuid, null: false, foreign_key: true
      t.references :activity, type: :uuid, foreign_key: { on_delete: :nullify }
      t.references :assigned_by, type: :uuid, foreign_key: { to_table: :participants, on_delete: :nullify }
      t.string :assigned_by_name, null: false
      t.string :title
      t.text :details
      t.datetime :starts_at
      t.string :location
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
