# Deja la base lista para cargar los datos reales del evento: borra a todas las personas y lo que se hizo con
# ellas, y conserva las cuentas de superadmin y lo que es configuración. Lo corre `bin/rails datos:reiniciar`.
#
# Se borra: fichas (con sus cuentas y fotos), compañías y compañías auxiliares, registro de llegadas y
# capacitaciones, asignaciones, enfermería, asistencia nocturna, alertas, gastos (con sus facturas),
# inventarios con sus artículos y movimientos, cargas masivas, intentos de inicio de sesión y el historial.
# Se queda: las cuentas de superadmin (sin ficha), la configuración, las categorías de gasto, las áreas de
# logística (vacías), las capacitaciones (sin asistencia) y la agenda (sin responsables).
class EventReset
  # Lo que se borra, en el orden en que se muestra.
  COUNTS = {
    "Fichas" => -> { Participant.count },
    "Cuentas (sin contar superadmins)" => -> { User.where(superadmin: false).count },
    "Compañías" => -> { Company.count },
    "Compañías auxiliares" => -> { AuxiliarCompany.count },
    "Llegadas registradas" => -> { Checkin.count },
    "Asistencias a capacitaciones" => -> { TrainingAttendance.count },
    "Asignaciones" => -> { Assignment.count },
    "Visitas a enfermería" => -> { InfirmaryVisit.count },
    "Listas de asistencia nocturna" => -> { NightAttendance.count },
    "Alertas" => -> { Alert.count },
    "Gastos" => -> { Expense.count },
    "Inventarios" => -> { Inventory.count },
    "Artículos de inventario" => -> { InventoryItem.count },
    "Cargas masivas" => -> { ParticipantImport.count },
    "Entradas del historial" => -> { AuditLog.count }
  }.freeze

  KEPT = {
    "Superadmins" => -> { User.where(superadmin: true).count },
    "Áreas de logística" => -> { LogisticsArea.count },
    "Categorías de gasto" => -> { ExpenseCategory.count },
    "Capacitaciones" => -> { Training.count },
    "Actividades de la agenda" => -> { Activity.count }
  }.freeze

  def self.counts = COUNTS.transform_values(&:call)
  def self.kept = KEPT.transform_values(&:call)

  def initialize(out: $stdout)
    @out = out
  end

  def run
    ActiveRecord::Base.transaction do
      AuditLog.delete_all
      LoginAttempt.delete_all
      ParticipantImport.delete_all # sus filas se van en cascada
      # destroy, no delete: así Active Storage borra también las imágenes y las facturas de R2.
      Alert.find_each(&:destroy!)
      Expense.find_each(&:destroy!)
      InfirmaryVisit.find_each(&:destroy!)
      InventoryMovement.delete_all
      InventoryItem.delete_all
      Inventory.delete_all
      NightAttendance.delete_all # sus marcas se van en cascada
      Checkin.delete_all
      TrainingAttendance.delete_all
      Assignment.delete_all
      ActivityResponsible.delete_all
      Membership.delete_all
      # El superadmin se queda sin ficha: borrar la ficha borraría su cuenta.
      User.where(superadmin: true).update_all(participant_id: nil)
      Participant.where.not(company_id: nil).update_all(company_id: nil)
      Company.delete_all
      AuxiliarCompany.delete_all
      # destroy: se llevan su cuenta (con sus sesiones) y su foto.
      Participant.find_each(&:destroy!)
      User.where(superadmin: false).find_each(&:destroy!)
      AuditLog.create!(actor_name: "Administrador del sistema", action: "deleted", category: :participantes,
                       summary: "Reinició los datos del evento: se borraron todas las fichas y lo que se hizo con ellas")
    end
    @out.puts "Listo. Las fotos y facturas se borran de R2 en segundo plano, la próxima vez que la app esté despierta."
  end
end
