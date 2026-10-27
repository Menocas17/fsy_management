# The event itself: the agenda covers these days and the dashboard counts down to the first one.
# El nombre es uno solo en pantalla, correos y PDF (el evento es en enero de 2027, pero se llama FSY 2026).
Rails.application.config.x.event_name = "FSY 2026"
Rails.application.config.x.event_region = "Managua-Caribe"
Rails.application.config.x.event_start_on = Date.new(2027, 1, 11)
Rails.application.config.x.event_end_on = Date.new(2027, 1, 16)
# La agenda: el staff llega el domingo (Día 0 del manual) y los jóvenes el lunes; termina el viernes (Día 5),
# porque el sábado solo es la salida.
Rails.application.config.x.staff_start_on = Date.new(2027, 1, 10)
Rails.application.config.x.agenda_end_on = Date.new(2027, 1, 15)
Rails.application.config.x.event_start_hour = 7

# Quién firma las notificaciones push ante el servidor del navegador: un mailto: o https: real, que es a donde
# escriben si un envío falla. El de Apple puede rechazar uno de mentira (example.com, localhost), y entonces
# el iPhone no recibe nada: sin PUSH_SUBJECT firma la dirección de la app.
push_host = ENV["APP_HOST"].presence || ENV["RENDER_EXTERNAL_HOSTNAME"].presence
Rails.application.config.x.push_subject = ENV["PUSH_SUBJECT"].presence ||
                                          (push_host ? "https://#{push_host}" : "mailto:fsy@example.com")
