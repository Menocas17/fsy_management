# Usuarios a la vez, cada uno pidiendo pantallas de su rol con una pausa entre una y otra (60 % jóvenes,
# 30 % consejeros, 10 % dirección). Reporta peticiones por segundo y tiempos.
#   USUARIOS=650 PAUSA=12 SEGUNDOS=60 ruby -Iscript/carga script/carga/usuarios.rb
require "cliente"
require "config"

usuarios = Integer(ENV.fetch("USUARIOS", "100"))
segundos = Float(ENV.fetch("SEGUNDOS", "60"))
pausa = Float(ENV.fetch("PAUSA", "12"))

roles = Array.new(usuarios) { |i| (i % 10) < 6 ? Carga::JOVEN : ((i % 10) < 9 ? Carga::CONSEJERO : Carga::ADMIN) }
sesiones = roles.uniq.to_h { |email| [ email, Cliente.new(email).cookies ] }
clientes = roles.map { |email| [ email, Cliente.new(email, cookies: sesiones[email]) ] }

resultados = Queue.new
fin = Process.clock_gettime(Process::CLOCK_MONOTONIC) + segundos
hilos = clientes.map do |email, cliente|
  Thread.new do
    # Cada uno empieza en un momento distinto, como en la vida real (si no, todos piden en el segundo 0).
    sleep(rand * pausa) if pausa.positive?
    while Process.clock_gettime(Process::CLOCK_MONOTONIC) < fin
      resultados << cliente.get(Carga::PANTALLAS[email].sample).first(2)
      sleep(pausa * (0.5 + rand)) if pausa.positive?
    end
  end
end
hilos.each(&:join)

todos = Array.new(resultados.size) { resultados.pop }
tiempos = todos.map(&:last).sort
errores = todos.count { |codigo, _| codigo >= 400 }
puts format("%d usuarios (pausa ~%gs): %.1f peticiones/s · mediana %.0f ms · p95 %.0f ms · máx %.0f ms · errores %d de %d",
            usuarios, pausa, todos.size / segundos, Carga.percentil(tiempos, 0.5), Carga.percentil(tiempos, 0.95),
            tiempos.last, errores, todos.size)
