class AddAppearanceToExpenseCategories < ActiveRecord::Migration[8.1]
  def change
    # Icono y color como los inventarios, para reconocer cada categoría de un vistazo.
    add_column :expense_categories, :icon, :string, null: false, default: "wallet"
    add_column :expense_categories, :color, :string, null: false, default: "primary"
  end
end
