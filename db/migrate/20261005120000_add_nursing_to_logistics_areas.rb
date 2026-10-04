# Cuarta bandera de las áreas de logística: quién atiende la enfermería (ingresa y da de alta jóvenes y
# escribe su ficha clínica). Por bandera y no por nombre, como las otras.
class AddNursingToLogisticsAreas < ActiveRecord::Migration[8.1]
  def change
    add_column :logistics_areas, :nursing, :boolean, null: false, default: false
  end
end
