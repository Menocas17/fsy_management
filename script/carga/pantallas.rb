# Cuánto tarda cada pantalla con el servidor tranquilo: 2 de calentamiento y 10 medidas.
#   ruby -Iscript/carga script/carga/pantallas.rb
require "cliente"
require "config"

pantallas = {
  Carga::ADMIN => {
    "Inicio" => "/dashboard", "Lista de jóvenes" => "/participants", "Compañías" => "/companies",
    "Organigrama" => "/organigrama", "Agenda" => "/agenda", "Búsqueda" => "/buscar?q=mar",
    "PDF participantes" => "/reportes/participantes", "PDF cuartos" => "/reportes/cuartos",
    "PDF gafetes, una compañía" => "/reportes/gafetes?company=#{Carga::COMPANIA_ID}", "PDF gafetes, todos" => "/reportes/gafetes"
  },
  Carga::CONSEJERO => Carga::PANTALLAS[Carga::CONSEJERO].to_h { |path| [ "Consejero #{path}", path ] },
  Carga::JOVEN => Carga::PANTALLAS[Carga::JOVEN].to_h { |path| [ "Joven #{path}", path ] }
}

puts format("%-46s %5s %9s %9s %9s", "Pantalla", "HTTP", "mediana", "p90", "tamaño")
pantallas.each do |email, lista|
  cliente = Cliente.new(email)
  lista.each do |nombre, path|
    veces = nombre.include?("todos") ? 3 : 10
    2.times { cliente.get(path) }
    resultados = Array.new(veces) { cliente.get(path) }
    tiempos = resultados.map { _2 }.sort
    codigo, _, bytes = resultados.last
    puts format("%-46s %5d %7.0f ms %7.0f ms %7.0f KB", nombre[0, 46], codigo, Carga.percentil(tiempos, 0.5),
                Carga.percentil(tiempos, 0.9), bytes / 1024.0)
  end
end
