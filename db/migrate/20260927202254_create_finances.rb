class CreateFinances < ActiveRecord::Migration[8.1]
  def up
    # El área de logística que lleva las finanzas (hoy, «Finanzas»), igual que checkin marca la de Registro.
    add_column :logistics_areas, :finance, :boolean, null: false, default: false
    execute "UPDATE logistics_areas SET finance = TRUE WHERE name = 'Finanzas'"

    # Categorías opcionales; el presupuesto propio también lo es (sin él, cuenta contra el general).
    create_table :expense_categories, id: :uuid do |t|
      t.string :name, null: false
      t.bigint :budget_cents
      t.timestamps
    end
    add_index :expense_categories, "lower(name)", unique: true, name: "index_expense_categories_on_lower_name"

    create_table :expenses, id: :uuid do |t|
      t.references :expense_category, type: :uuid, foreign_key: true
      t.references :logistics_area, type: :uuid, foreign_key: true

      t.string :concept, null: false
      t.string :vendor
      t.text :notes
      # Montos en centavos de su moneda original; el tipo de cambio lleva a córdobas.
      t.string :currency, null: false, default: "NIO"
      t.decimal :exchange_rate, precision: 10, scale: 4, null: false, default: 1
      t.bigint :estimated_cents, null: false
      t.date :planned_on
      t.bigint :actual_cents
      t.date :spent_on
      t.integer :payment_method

      t.integer :status, null: false, default: 0

      # Cada paso guarda quién lo dio (y su nombre, por si luego se borra la ficha) y cuándo.
      t.references :presented_by, type: :uuid, foreign_key: { to_table: :participants }
      t.string :presented_by_name, null: false
      t.references :approved_by, type: :uuid, foreign_key: { to_table: :participants }
      t.string :approved_by_name
      t.datetime :approved_at
      t.references :rejected_by, type: :uuid, foreign_key: { to_table: :participants }
      t.string :rejected_by_name
      t.datetime :rejected_at
      t.text :rejection_reason
      t.text :justification
      t.references :justified_by, type: :uuid, foreign_key: { to_table: :participants }
      t.string :justified_by_name
      t.datetime :justified_at
      t.text :justification_rejection
      t.references :consolidated_by, type: :uuid, foreign_key: { to_table: :participants }
      t.string :consolidated_by_name
      t.datetime :consolidated_at

      t.timestamps
    end
    add_index :expenses, :status
  end

  def down
    drop_table :expenses
    drop_table :expense_categories
    remove_column :logistics_areas, :finance
  end
end
