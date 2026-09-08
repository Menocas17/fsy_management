class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies, id: :uuid do |t|
      t.string :name, null: false
      t.references :auxiliar_company, type: :uuid, foreign_key: { to_table: :auxiliar_companies }, null: true

      t.timestamps
    end
  end
end
