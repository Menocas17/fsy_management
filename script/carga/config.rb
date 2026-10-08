# Lo que comparten las dos pruebas: las cuentas de cada rol y las pantallas que abre cada uno el lunes.
# Las cuentas y los ids salen del entorno (script/carga/README.md).
module Carga
  ADMIN = ENV.fetch("EMAIL_ADMIN")
  CONSEJERO = ENV.fetch("EMAIL_CONSEJERO")
  JOVEN = ENV.fetch("EMAIL_JOVEN")
  # La compañía del consejero y un joven de ella; JOVEN_ID es la ficha de la cuenta de joven.
  COMPANIA_ID = ENV.fetch("COMPANIA_ID")
  JOVEN_DE_LA_COMPANIA_ID = ENV.fetch("JOVEN_DE_LA_COMPANIA_ID")

  PANTALLAS = {
    JOVEN => [ "/dashboard", "/participants/myprofile", "/agenda" ],
    CONSEJERO => [ "/dashboard", "/companies/#{COMPANIA_ID}", "/participants/#{JOVEN_DE_LA_COMPANIA_ID}" ],
    ADMIN => [ "/dashboard", "/participants", "/companies", "/buscar?q=mar", "/notificaciones" ]
  }.freeze

  def self.percentil(ordenados, p) = ordenados[((ordenados.size - 1) * p).round]
end
