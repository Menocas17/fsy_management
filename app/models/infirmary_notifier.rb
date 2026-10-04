# Los avisos de enfermería. Van a quienes cuidan al joven (InfirmaryVisit#care_team: los consejeros de su
# compañía y los auxiliares de su rama), en una sola alerta compartida, en la campanita y como push:
#   - cuando entra a enfermería;
#   - cuando sale, solo si se fue a casa o al hospital. Volver a su compañía no avisa.
# El aviso dice el motivo pero no el detalle: el detalle va en su ficha, que solo leen quienes deben.
module InfirmaryNotifier
  module_function

  def admitted(visit)
    joven = visit.participant
    notify(visit, sender: visit.admitted_by, sender_name: visit.admitted_by_name, priority: :importante,
                  title: "#{joven.full_name} está en enfermería",
                  body: "Entró a las #{visit.admitted_at.strftime("%H:%M")} por #{visit.reason_label.downcase}. " \
                        "#{joven.gender == "M" ? "La" : "Lo"} atiende #{visit.admitted_by_name}.")
  end

  def discharged(visit)
    return unless visit.disposition_casa? || visit.disposition_hospital?

    joven = visit.participant
    pronoun = joven.gender == "M" ? "la" : "lo"
    title = visit.disposition_hospital? ? "#{joven.full_name}: #{pronoun} llevaron al hospital" : "#{joven.full_name} se fue a casa"
    notify(visit, sender: visit.discharged_by, sender_name: visit.discharged_by_name,
                  priority: visit.disposition_hospital? ? :critica : :importante, title: title,
                  body: "Salió de enfermería a las #{visit.discharged_at.strftime("%H:%M")}. Abre su ficha para ver el detalle.")
  end

  def notify(visit, sender:, sender_name:, priority:, title:, body:)
    ids = visit.care_team.map(&:id)
    return if ids.empty?

    Alert.create!(title: title.truncate(120), body: body, audience: :personas, recipient_ids: ids, priority: priority,
                  source: :enfermeria, sender: sender, sender_name: sender_name,
                  link_path: Rails.application.routes.url_helpers.infirmary_chart_path(visit.participant))
  end
end
