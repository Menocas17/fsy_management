class MoveParticipantAuditLogsToParticipantes < ActiveRecord::Migration[8.1]
  # Registrar, editar, borrar y cargar fichas se anotaba como «Asignaciones», junto a las asignaciones de
  # verdad: filtrar por una u otra mezclaba las dos. Ahora tienen su categoría (participantes = 8).
  def up
    execute <<~SQL
      UPDATE audit_logs SET category = 8
      WHERE category = 2
        AND (target_type = 'Participant' OR action = 'imported')
        AND summary NOT LIKE 'Asignó %' AND summary NOT LIKE 'Quitó %'
    SQL
  end

  def down
    execute "UPDATE audit_logs SET category = 2 WHERE category = 8"
  end
end
