# Tercera bandera de las áreas de logística, junto a checkin y finance: quién tendrá acceso al módulo de
# alimentación (todavía no existe). Por bandera y no por nombre, como las otras dos.
class AddFoodToLogisticsAreas < ActiveRecord::Migration[8.1]
  def change
    add_column :logistics_areas, :food, :boolean, null: false, default: false
  end
end
