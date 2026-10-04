# El aviso de la asistencia nocturna: a las 10 pm (NightAttendanceCheckJob), si en alguna compañía falta
# alguien —su lista no se ha pasado o alguien quedó ausente—, sale un solo aviso con todo junto (aunque
# falten 20, es un aviso, no 20). Lo reciben los auxiliares, los coordinadores y el matrimonio director, en
# la campanita y como push, y abre el panel de esa noche.
module NightAttendanceNotifier
  RECIPIENT_ROLES = %w[auxiliar coordinador director].freeze

  module_function

  # Una vez por noche aunque el job corra dos veces. Sin faltantes, no hay aviso.
  def nightly_check(night)
    key = "night_attendance_alerted:#{night.iso8601}"
    return if AppSetting[key].present?

    AppSetting[key] = Time.current.iso8601
    report = issues(night)
    return if report.empty?

    pending = report.count { |line| line[:pending] }
    absent = report.sum { |line| line[:absent].size }
    title = [ (pluralize(pending, "lista sin pasar", "listas sin pasar") if pending.positive?),
              (pluralize(absent, "joven ausente", "jóvenes ausentes") if absent.positive?) ].compact.join(" y ")

    Alert.create!(title: "Asistencia nocturna: #{title}".truncate(120), body: report.map { |line| line[:text] }.join("\n"),
                  audience: :por_roles, target_roles: RECIPIENT_ROLES, priority: :importante, source: :asistencia,
                  sender_name: "Asistencia nocturna", link_path: url_helpers.night_attendances_path(noche: night.iso8601))
  end

  # Una línea por lista con faltantes: «Compañía 3 · hombres: sin pasar» o «… : Pedro López (Enfermería)».
  def issues(night)
    attendances = NightAttendance.where(night_on: night).includes(marks: :participant).index_by { |a| [ a.company_id, a.gender ] }
    expected = Participant.joven.where.not(company_id: nil).where.not(gender: nil)
                          .group(:company_id, :gender).pluck(:company_id, :gender, Arel.sql("array_agg(participants.id)"))
    companies = Company.where(id: expected.map(&:first)).index_by(&:id)

    expected.sort_by { |company_id, gender, _| [ companies[company_id].number.to_i, gender.to_s ] }.filter_map do |company_id, gender, ids|
      label = "#{companies[company_id].name} · #{NightAttendance.gender_label(gender).downcase}"
      attendance = attendances[[ company_id, gender ]]
      next { text: "#{label}: sin pasar", pending: true, absent: [] } if attendance.nil?

      missing = attendance.missing_ids(ids)
      next if missing.empty?

      unmarked = Participant.where(id: missing).index_by(&:id)
      names = missing.map do |id|
        mark = attendance.marks.find { |m| m.participant_id == id }
        mark ? "#{mark.participant.full_name} (#{mark.reason_label})" : "#{unmarked[id].full_name} (sin marcar)"
      end
      { text: "#{label}: #{names.join(', ')}", pending: false, absent: missing }
    end
  end

  def pluralize(count, singular, plural)
    "#{count} #{count == 1 ? singular : plural}"
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
