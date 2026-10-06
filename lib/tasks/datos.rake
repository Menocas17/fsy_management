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

  desc "Borra todo como datos:reiniciar y carga los datos de prueba de docs/cargas_de_prueba, ya repartidos en compañías"
  task sembrar: :environment do
    if Rails.env.production? && ENV["CONFIRMAR"] != "1"
      abort "Esto borra los datos de PRODUCCIÓN. Si es lo que quieres: CONFIRMAR=1 bin/rails datos:sembrar"
    end

    database = ActiveRecord::Base.connection_db_config.configuration_hash
    puts "Base: #{database[:host] || "local"} / #{database[:database]} (#{Rails.env})", ""
    puts "Se borra:"
    EventReset.counts.each { |label, count| puts format("  %-36s %6d", label, count) }
    puts "", "Se queda:"
    EventReset.kept.each { |label, count| puts format("  %-36s %6d", label, count) }
    puts "", "Y se cargan 25 compañías, la dirección, la logística, 50 consejeros y 512 jóvenes ya repartidos,",
         "la agenda (reemplaza la que haya), inventarios, capacitaciones, gastos y algunas asignaciones."
    if (missing = EventSeed.missing_areas).any?
      puts "", "Ojo: no existen las áreas #{missing.to_sentence(two_words_connector: " y ", last_word_connector: " y ")}: " \
               "su logística quedaría sin área. Créalas antes en Logística › Áreas."
    end
    puts "", "No se puede deshacer: haz antes un pg_dump.", "Escribe SEMBRAR para continuar:"

    abort "Cancelado: no se borró nada." unless $stdin.gets.to_s.strip == "SEMBRAR"

    EventSeed.new.run
  end
end
