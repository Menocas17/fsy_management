class AddSecondCoordinatorToAuxiliarCompanies < ActiveRecord::Migration[8.1]
  def change
    add_reference :auxiliar_companies, :second_coordinator, type: :uuid, foreign_key: { to_table: :participants }
  end
end
