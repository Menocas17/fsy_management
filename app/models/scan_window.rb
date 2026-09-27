# Cuándo se puede escanear un registro (la llegada al FSY o una capacitación). Por defecto solo el día
# que toca, para que nadie registre por error en la de diciembre; el superadmin puede dejarlo abierto
# o cerrado a mano desde Configuración.
class ScanWindow
  MODES = { "auto" => "Solo el día", "open" => "Abierto", "closed" => "Cerrado" }.freeze
  ARRIVAL_KEY = "arrival_scan_mode"

  attr_reader :day, :mode

  def self.arrival
    new(day: Rails.configuration.x.event_start_on, mode: AppSetting[ARRIVAL_KEY])
  end

  def self.for(training)
    training ? new(day: training.held_on, mode: training.scan_mode) : arrival
  end

  def initialize(day:, mode:)
    @day = day
    @mode = MODES.key?(mode.to_s) ? mode.to_s : "auto"
  end

  # at: cuándo se escaneó. Lo que se escaneó sin señal el día que tocaba entra aunque llegue después.
  def open?(at = Time.current)
    case mode
    when "open" then true
    when "closed" then false
    else at.to_date == day
    end
  end

  def closed_reason
    return "El administrador cerró este registro." if mode == "closed"

    day > Date.current ? "Se abre el #{SpanishDates.long(day, capitalize: false)}." : "Se cerró al terminar el #{SpanishDates.long(day, capitalize: false)}."
  end
end
