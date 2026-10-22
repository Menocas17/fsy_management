class CreateManuals < ActiveRecord::Migration[8.1]
  def change
    create_table :manuals, id: :uuid do |t|
      t.integer :kind, null: false
      t.string :uploaded_by_name
      t.timestamps
    end
    add_index :manuals, :kind, unique: true
  end
end
