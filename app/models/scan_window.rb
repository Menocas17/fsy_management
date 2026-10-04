# Qué registro se está escaneando: la llegada al FSY o una capacitación. Solo hay uno activo a la vez y lo
# elige a mano, desde Configuración, el superadmin o el director de logística; activar uno cierra el que
# estaba. Sin ninguno activo, el escáner está cerrado.
class ScanWindow
  ACTIVE_KEY = "active_scan"
  ACTIVE_SINCE_KEY = "active_scan_since"
  # El último que se cerró y entre qué horas estuvo abierto ("clave|desde|hasta"): lo escaneado sin señal
  # mientras estaba activo entra aunque llegue después de cambiar al siguiente.
  PREVIOUS_KEY = "previous_scan"

  attr_reader :key

  def self.arrival
    new("arrival")
  end

  def self.for(training)
    training ? new("training:#{training.id}") : arrival
  end

  def self.active
    key = AppSetting[ACTIVE_KEY].presence
    new(key) if key
  end

  # La capacitación activa, o nil si lo activo es la llegada (o nada).
  def self.active_training
    id = active&.training_id
    Training.find_by(id: id) if id
  end

  # window: el que se abre, o nil para cerrar el que haya.
  def self.activate!(window)
    AppSetting.transaction do
      current = active
      if current && current.key != window&.key
        AppSetting[PREVIOUS_KEY] = [ current.key, AppSetting[ACTIVE_SINCE_KEY], Time.current.iso8601 ].join("|")
      end
      AppSetting[ACTIVE_KEY] = window&.key.to_s
      AppSetting[ACTIVE_SINCE_KEY] = Time.current.iso8601 unless current&.key == window&.key
    end
  end

  def initialize(key)
    @key = key
  end

  def arrival?
    key == "arrival"
  end

  def training_id
    key.delete_prefix("training:") unless arrival?
  end

  def active?
    AppSetting[ACTIVE_KEY] == key
  end

  # at: cuándo se escaneó.
  def open?(at = Time.current)
    return true if active?

    previous_key, from, to = AppSetting[PREVIOUS_KEY].to_s.split("|")
    previous_key == key && from.present? && to.present? && at.between?(Time.zone.parse(from), Time.zone.parse(to))
  end

  def closed_reason
    "No está activo. Lo activa el director de logística o el administrador desde Configuración."
  end
end
