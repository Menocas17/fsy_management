# Los avisos de la asistencia nocturna. Solo hay aviso si a partir de las 10 pm falta alguien en una compañía:
# su lista no se ha pasado o alguien quedó ausente. Llegan al auxiliar y al coordinador de su rama y al
# matrimonio director (NightAttendance.watchers_for), a la campanita y como push.
#   - A las 10 pm (NightAttendanceCheckJob), un resumen por persona con lo que le toca.
#   - Después, cada ausencia nueva que se marque esa noche.
module NightAttendanceNotifier
  module_function

  # El resumen de las 10 pm. Una vez por noche aunque el job corra dos veces.
  def nightly_check(night)
    key = "night_attendance_alerted:#{night.iso8601}"
    return if AppSetting[key].present?

    AppSetting[key] = Time.current.iso8601
    lines_by_watcher = Hash.new { |hash, id| hash[id] = [] }

    issues(night).each do |company, line|
      NightAttendance.watchers_for(company).pluck(:id).each { |id| lines_by_watcher[id] << line }
    end

    lines_by_watcher.each do |participant_id, lines|
      notify(participant_id, "Asistencia nocturna: #{ActionController::Base.helpers.pluralize(lines.size, 'lista', plural: 'listas')} con faltantes",
             lines.join("\n"), link: panel_path(night))
    end
  end

  # Una ausencia marcada después de las 10 pm.
  def absences(attendance, participant_ids)
    return if participant_ids.empty?

    names = attendance.marks.select { |mark| participant_ids.include?(mark.participant_id) }
                      .map { |mark| "#{mark.participant.full_name} (#{mark.reason_label})" }
    title = "Ausente en #{attendance.company.name}: #{names.size == 1 ? names.first : "#{names.size} jóvenes"}"
    body = "#{attendance.taken_by_name} pasó la asistencia de los #{attendance.gender_label.downcase}. Ausentes: #{names.join(', ')}."
    link = url_helpers.company_night_attendance_path(attendance.company, genero: attendance.gender)

    NightAttendance.watchers_for(attendance.company).pluck(:id).each { |id| notify(id, title, body, link: link) }
  end

  # [company, "Compañía 3 · hombres: sin pasar"] por cada lista con faltantes.
  def issues(night)
    attendances = NightAttendance.where(night_on: night).includes(marks: :participant).index_by { |a| [ a.company_id, a.gender ] }
    expected = Participant.joven.where.not(company_id: nil).group(:company_id, :gender).pluck(:company_id, :gender, Arel.sql("array_agg(id)"))

    companies = Company.where(id: expected.map(&:first)).includes(:auxiliar_company).index_by(&:id)
    expected.sort_by { |company_id, gender, _| [ companies[company_id].number.to_i, gender.to_s ] }.filter_map do |company_id, gender, ids|
      next if gender.blank?

      company = companies[company_id]
      attendance = attendances[[ company_id, gender ]]
      label = "#{company.name} · #{NightAttendance.gender_label(gender).downcase}"
      next [ company, "#{label}: sin pasar" ] if attendance.nil?

      missing = attendance.missing_ids(ids)
      next if missing.empty?

      unmarked = Participant.where(id: missing).index_by(&:id)
      names = missing.map do |id|
        mark = attendance.marks.find { |m| m.participant_id == id }
        mark ? "#{mark.participant.full_name} (#{mark.reason_label})" : "#{unmarked[id].full_name} (sin marcar)"
      end
      [ company, "#{label}: #{names.join(', ')}" ]
    end
  end

  def notify(participant_id, title, body, link:)
    Alert.create!(title: title.truncate(120), body: body, audience: :individual, recipient_id: participant_id,
                  priority: :importante, source: :asistencia, sender_name: "Asistencia nocturna", link_path: link)
  end

  def panel_path(night)
    url_helpers.night_attendances_path(noche: night.iso8601)
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
