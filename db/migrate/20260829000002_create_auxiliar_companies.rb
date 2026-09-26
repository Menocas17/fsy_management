class CreateAuxiliarCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :auxiliar_companies, id: :uuid do |t|
      t.string :name, null: false
      t.references :coordinator, type: :uuid, foreign_key: { to_table: :participants }, null: true

      t.timestamps
    end
  end
end
