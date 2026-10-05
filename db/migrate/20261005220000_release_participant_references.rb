# Borrar una ficha fallaba (500) si la persona era responsable de una actividad, había registrado llegadas o
# capacitaciones, movido inventario, presentado o aprobado un gasto, o coordinaba una compañía auxiliar: esas
# llaves no decían qué hacer. Ser responsable se borra con ella; en lo demás queda su nombre guardado
# (recorded_by_name, participant_name, approved_by_name…), así que solo se suelta el enlace.
class ReleaseParticipantReferences < ActiveRecord::Migration[8.1]
  CASCADE = [ [ :activity_responsibles, :participant_id ] ].freeze
  NULLIFY = [
    [ :checkins, :recorded_by_id ], [ :training_attendances, :recorded_by_id ], [ :inventory_movements, :participant_id ],
    [ :auxiliar_companies, :coordinator_id ], [ :auxiliar_companies, :second_coordinator_id ],
    [ :expenses, :presented_by_id ], [ :expenses, :approved_by_id ], [ :expenses, :rejected_by_id ],
    [ :expenses, :justified_by_id ], [ :expenses, :consolidated_by_id ]
  ].freeze

  def up
    replace(CASCADE, on_delete: :cascade)
    replace(NULLIFY, on_delete: :nullify)
  end

  def down
    replace(CASCADE + NULLIFY, on_delete: nil)
  end

  private
    def replace(keys, on_delete:)
      keys.each do |table, column|
        remove_foreign_key table, :participants, column: column
        add_foreign_key table, :participants, column: column, on_delete: on_delete
      end
    end
end
