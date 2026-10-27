namespace :agenda do
  desc "Reemplaza la agenda por la del Manual del consejero (días 1 a 5, lib/event_agenda.rb)"
  task manual: :environment do
    if Rails.env.production? && ENV["CONFIRMAR"] != "1"
      abort "Esto reemplaza la agenda de PRODUCCIÓN. Si es lo que quieres: CONFIRMAR=1 bin/rails agenda:manual"
    end

    database = ActiveRecord::Base.connection_db_config.configuration_hash
    linked = Assignment.where.not(activity_id: nil).count
    puts "Base: #{database[:host] || "local"} / #{database[:database]} (#{Rails.env})", "",
         "Se borran las #{Activity.count} actividades de la agenda y se cargan las #{EventAgenda::DAYS.sum(&:size)} del manual.",
         "Los devocionales y lo especial quedan a cargo de la dirección y los coordinadores."
    puts "Ojo: #{linked} asignaciones apuntan a una actividad de ahora y se quedarían sin ella." if linked.positive?
    puts "Escribe AGENDA para continuar:"

    abort "Cancelado: no se cambió nada." unless $stdin.gets.to_s.strip == "AGENDA"

    hosts = Participant.where(rol: %i[director coordinador]).order(:rol, :gender).to_a
    puts "✔ Agenda: #{EventAgenda.new(hosts: hosts).create} actividades"
  end
end
