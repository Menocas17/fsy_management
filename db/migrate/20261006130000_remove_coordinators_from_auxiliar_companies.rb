# Los dos coordinadores cuidan de todas las compañías auxiliares: ya no se eligen por rama. Quiénes son lo
# dice el rol (Participant.coordinador), no estas columnas.
class RemoveCoordinatorsFromAuxiliarCompanies < ActiveRecord::Migration[8.1]
  def change
    remove_reference :auxiliar_companies, :coordinator, type: :uuid, index: true,
                     foreign_key: { to_table: :participants, on_delete: :nullify }
    remove_reference :auxiliar_companies, :second_coordinator, type: :uuid, index: true,
                     foreign_key: { to_table: :participants, on_delete: :nullify }
  end
end
