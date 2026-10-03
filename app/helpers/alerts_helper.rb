module AlertsHelper
  # A dónde lleva tocar una alerta: el enlace que trae (finanzas), lo que anuncia (la actividad en la agenda,
  # la asignación en tu perfil) o, si no apunta a nada, la alerta misma.
  def alert_destination_path(alert)
    return alert.link_path if alert.link_path.to_s.match?(%r{\A/(?![/\\])})
    return myprofile_participants_path if alert.source_asignacion?
    return agenda_path(date: alert.activity.day, activity_id: alert.activity.id) if alert.activity

    alert_path(alert)
  end

  def alerts_total_label(count)
    count.positive? ? pluralize(count, "alerta", plural: "alertas") : "Sin alertas por ahora"
  end
end
