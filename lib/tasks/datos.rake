namespace :datos do
  desc "Borra todas las fichas y lo que se hizo con ellas, para cargar los datos reales (conserva superadmins y configuración)"
  task reiniciar: :environment do
    if Rails.env.production? && ENV["CONFIRMAR"] != "1"
      abort "Esto borra los datos de PRODUCCIÓN. Si es lo que quieres: CONFIRMAR=1 bin/rails datos:reiniciar"
    end

    database = ActiveRecord::Base.connection_db_config.configuration_hash
    puts "Base: #{database[:host] || "local"} / #{database[:database]} (#{Rails.env})", ""
    puts "Se borra:"
    EventReset.counts.each { |label, count| puts format("  %-36s %6d", label, count) }
    puts "", "Se queda:"
    EventReset.kept.each { |label, count| puts format("  %-36s %6d", label, count) }
    puts "", "Las cuentas de superadmin quedan sin ficha. No se puede deshacer: haz antes un pg_dump.",
         "Escribe BORRAR para continuar:"

    abort "Cancelado: no se borró nada." unless $stdin.gets.to_s.strip == "BORRAR"

    EventReset.new.run
  end

  desc "Borra todo como datos:reiniciar y carga la foto db/seed_data/evento.json, exactamente como quedó (conserva superadmins)"
  task sembrar: :environment do
    confirm_wipe!("sembrar", "SEMBRAR",
                  "Y se carga db/seed_data/evento.json tal cual: fichas, compañías, agenda (reemplaza la que haya),",
                  "inventarios, capacitaciones, gastos, asignaciones y asistencia.") do
      missing = EventSnapshot.missing_areas
      "Se crearán las áreas que faltan: #{missing.to_sentence(two_words_connector: " y ", last_word_connector: " y ")}." if missing.any?
    end
    EventSnapshot.new.run
  end

  desc "Borra todo y genera los datos de prueba desde los Excel de docs/cargas_de_prueba (sin la foto)"
  task generar: :environment do
    confirm_wipe!("generar", "GENERAR",
                  "Y se generan desde los Excel: 25 compañías, la dirección, la logística, 50 consejeros y 512 jóvenes,",
                  "la agenda (reemplaza la que haya), inventarios, capacitaciones, gastos y algunas asignaciones.") do
      missing = EventSeed.missing_areas
      "Ojo: no existen las áreas #{missing.to_sentence(two_words_connector: " y ", last_word_connector: " y ")}: su logística quedaría sin área." if missing.any?
    end
    EventSeed.new.run
  end

  desc "Guarda los datos de esta base en db/seed_data/evento.json, la foto que carga datos:sembrar"
  task exportar: :environment do
    abort "La foto va al repo, que es público: se toma de una base local con datos de prueba, nunca de producción." if Rails.env.production?

    EventSnapshot.dump.each { |table, count| puts format("  %-28s %5d", table, count) }
    puts "", "Guardado en db/seed_data/evento.json. Revisa el diff antes de hacer commit."
  end

  # Lo que tienen en común las tareas que borran: a qué base, qué se va, qué se queda y escribir la palabra.
  def confirm_wipe!(task, word, *loads)
    if Rails.env.production? && ENV["CONFIRMAR"] != "1"
      abort "Esto borra los datos de PRODUCCIÓN. Si es lo que quieres: CONFIRMAR=1 bin/rails datos:#{task}"
    end

    database = ActiveRecord::Base.connection_db_config.configuration_hash
    puts "Base: #{database[:host] || "local"} / #{database[:database]} (#{Rails.env})", ""
    puts "Se borra:"
    EventReset.counts.each { |label, count| puts format("  %-36s %6d", label, count) }
    puts "", "Se queda:"
    EventReset.kept.each { |label, count| puts format("  %-36s %6d", label, count) }
    puts "", *loads
    if (warning = yield)
      puts "", warning
    end
    puts "", "No se puede deshacer: haz antes un pg_dump.", "Escribe #{word} para continuar:"

    abort "Cancelado: no se borró nada." unless $stdin.gets.to_s.strip == word
  end
end
