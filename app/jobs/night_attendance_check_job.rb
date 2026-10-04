# A las 10 pm de cada noche del evento: avisa de las listas sin pasar y de los ausentes (config/recurring.yml).
class NightAttendanceCheckJob < ApplicationJob
  queue_as :default

  def perform
    night = NightAttendance.current_night
    NightAttendanceNotifier.nightly_check(night) if NightAttendance.event_nights.include?(night)
  end
end
