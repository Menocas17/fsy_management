class CreateLogisticsAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :logistics_areas, id: :uuid do |t|
      t.string :name, null: false
      t.string :description
      t.timestamps
    end
    add_index :logistics_areas, :name, unique: true

    add_reference :participants, :logistics_area, type: :uuid, foreign_key: { on_delete: :nullify }
  end
end
