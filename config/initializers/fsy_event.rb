# The event itself: the agenda covers these days and the dashboard counts down to the first one.
# El nombre es uno solo en pantalla, correos y PDF (el evento es en enero de 2027, pero se llama FSY 2026).
Rails.application.config.x.event_name = "FSY 2026"
Rails.application.config.x.event_region = "Managua-Caribe"
Rails.application.config.x.event_start_on = Date.new(2027, 1, 11)
Rails.application.config.x.event_end_on = Date.new(2027, 1, 16)
Rails.application.config.x.event_start_hour = 7

# Quién firma las notificaciones push ante el servidor del navegador. Debe ser un mailto: o https:
# real: si un envío falla, es a esta dirección a la que escriben.
# Cambiar por el correo real del comité antes de producción: es a donde escriben si un envío falla.
Rails.application.config.x.push_subject = ENV.fetch("PUSH_SUBJECT", "mailto:from@example.com")
