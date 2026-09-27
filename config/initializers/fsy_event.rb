# The event itself: the agenda covers these days and the dashboard counts down to the first one.
Rails.application.config.x.event_start_on = Date.new(2027, 1, 11)
Rails.application.config.x.event_end_on = Date.new(2027, 1, 16)
Rails.application.config.x.event_start_hour = 7

# Capacitaciones del staff, en orden. Van aquí mientras no exista un modelo de capacitaciones: agregar una
# es una línea más, y el panel deja de mostrar solas las que ya pasaron.
# El panel muestra las dos próximas y, después de ellas, el arranque del evento.
# Quién firma las notificaciones push ante el servidor del navegador. Debe ser un mailto: o https:
# real: si un envío falla, es a esta dirección a la que escriben.
# Cambiar por el correo real del comité antes de producción: es a donde escriben si un envío falla.
Rails.application.config.x.push_subject = ENV.fetch("PUSH_SUBJECT", "mailto:from@example.com")

Rails.application.config.x.training_dates = [
  Date.new(2026, 10, 17),
  Date.new(2026, 11, 17),
  Date.new(2026, 12, 17)
].freeze
