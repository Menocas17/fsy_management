# El tutorial de la app (solo en el teléfono, con el modo simple): un recorrido de unos 5 minutos por las
# páginas de verdad que ilumina una parte a la vez (tour_controller.js). Cada paso dice en qué página va
# (path), qué ilumina (target, un selector CSS) y qué se hace:
#
#   info     se lee y se sigue con «Siguiente»
#   tap      se toca lo iluminado (si es un enlace, el tutorial va a la página del paso siguiente)
#   play     se usa de verdad y se sigue con «Siguiente» (el modo oscuro)
#   locked   se ve pero no se mueve durante el tutorial (el modo simple)
#   practice se hace el gesto real (deslizar y borrar, avisar, confirmar, enviar) y el envío se frena: no se guarda
#   real     se hace de verdad porque no afecta a nadie (borrar su propia alerta de bienvenida)
#
# Lo que le toca a cada quien sale de lo que puede hacer, no del nombre del rol. Los textos viven en
# config/tutorial.yml. Practicar llevar a enfermería y el Conteo usa los jóvenes de práctica (PracticeMode).
class Tutorial
  include Rails.application.routes.url_helpers

  TEXTS = YAML.load_file(Rails.root.join("config/tutorial.yml")).freeze

  WELCOME_ALERT = {
    title: "Bienvenida a FSY 2026",
    body: "Te la envió el tutorial, solo a ti, para practicar cómo se borra una alerta deslizándola. Puedes borrarla sin problema."
  }.freeze

  def self.available_to?(user)
    user.present? && user.simple_mode? && user.participant&.staff_member? || false
  end

  # La alerta con la que se practica borrar: una por persona, y se va al terminar el tutorial.
  def self.welcome_alert_for(user)
    Alert.source_tutorial.find_by(recipient: user.participant) ||
      Alert.create!(WELCOME_ALERT.merge(source: :tutorial, audience: :individual, recipient: user.participant,
                                        priority: :informativa, sender_name: "Tutorial"))
  end

  def self.finish!(user)
    user.update!(tutorial_completed_at: Time.current)
    Alert.source_tutorial.where(recipient: user.participant).destroy_all
  end

  def initialize(user)
    @user = user
    @participant = user.participant
  end

  def steps
    [
      step(:welcome, dashboard_path),
      step(:kpis, dashboard_path, target: "[data-simple-kpis]"),
      *own_steps,
      *infirmary_steps,
      step(center_key, dashboard_path, target: "[data-tour='center']"),
      *agenda_steps,
      *training_steps,
      step(:bell, dashboard_path, target: "[data-tour='bell']", action: :tap),
      step(:notification_swipe, notifications_path, target: "[data-alert-tutorial]", action: :real),
      step(:more, dashboard_path, target: "[data-tour='more']", action: :tap),
      step(:sheet_scan, dashboard_path, target: "[data-more-items] a[href='#{scan_path}']", action: :tap),
      step(:scan, scan_path, target: "[data-controller~='qr-scanner']"),
      *conteo_steps,
      *alert_steps,
      step(:account, dashboard_path, target: "[data-tour='account']", action: :tap),
      step(:settings_link, dashboard_path, target: "[data-tour='settings-link']", action: :tap),
      step(:theme, settings_path, target: "[data-tour='theme']", action: :play),
      step(:simple_mode, settings_path, target: "#settings-simple", action: :locked),
      step(:done, dashboard_path)
    ]
  end

  private
    def step(key, path, target: nil, action: :info)
      text = TEXTS.fetch(key.to_s)
      values = { name: @participant.preferred_name.presence || @participant.first_name, role_notes: role_notes }
      {
        id: key.to_s, path: path, target: target, action: action.to_s,
        title: format(text.fetch("title"), values), text: format(text.fetch("text"), values),
        result_title: text["result_title"], result: text["result"]
      }.compact
    end

    # El botón de su rol en la barra (NavigationHelper#simple_own_item).
    def own_steps
      case @participant.rol
      when "consejero" then practice_company ? [ step(:own_company, dashboard_path, target: "[data-tour='own']", action: :tap) ] : []
      when "auxiliar" then practice_company ? [ step(:own_branch, dashboard_path, target: "[data-tour='own']", action: :tap) ] : []
      when "logistica"
        @user.checkin_member? ? [ step(:own_checkin, dashboard_path, target: "[data-tour='own']") ] : [ step(:own_area, dashboard_path, target: "[data-tour='own']") ]
      else [ step(:own_companies, dashboard_path, target: "[data-tour='own']") ]
      end
    end

    # Consejero y auxiliar: llevar a un joven de práctica a enfermería, de la compañía a su ficha y al aviso.
    def infirmary_steps
      return [] unless practice_company

      joven = Participant.practice_jovenes.first
      [
        step(:practice_joven, company_path(practice_company, practica: "1"), target: "[data-practice-joven]", action: :tap),
        step(:ficha_infirmary, participant_path(joven, practica: "1"), target: "[data-profile-infirmary]", action: :tap),
        step(:chart_announce, infirmary_chart_path(joven, practica: "1"), target: "[data-tour='announce']", action: :tap),
        step(:announce_reason, new_infirmary_visit_path(participant_id: joven.id, practica: "1"), target: "[data-infirmary-form] fieldset", action: :play),
        step(:announce_form, new_infirmary_visit_path(participant_id: joven.id, practica: "1"), target: "[data-infirmary-form] button[type='submit']", action: :practice)
      ]
    end

    def agenda_steps
      tab = step(:agenda_tab, dashboard_path, target: "[data-tour='agenda']", action: :tap)
      return [ tab, step(:agenda_empty, agenda_path) ] unless Activity.exists?

      [
        tab,
        step(:activity, agenda_path, target: "details.agenda-details", action: :tap),
        step(:activity_detail, agenda_path, target: "details.agenda-details[open]")
      ]
    end

    # Quien edita la agenda borra capacitaciones deslizándolas; se practica con una de verdad sin borrarla.
    def training_steps
      return [] unless @user.agenda_manager? && Training.exists?

      [
        step(:trainings_tab, agenda_path, target: "a[href='#{agenda_trainings_path}']", action: :tap),
        step(:training_swipe, agenda_trainings_path, target: "[data-controller~='alert-item']:has([data-training-card])", action: :practice)
      ]
    end

    def conteo_steps
      return [] unless practice_company && @participant.gender.present?

      [
        step(:more_conteo, dashboard_path, target: "[data-tour='more']", action: :tap),
        step(:sheet_conteo, dashboard_path, target: "[data-more-items] a[href*='asistencia-nocturna']", action: :tap),
        step(:conteo_mark, company_night_attendance_path(practice_company, genero: @participant.gender, practica: "1"),
             target: "[data-night-attendance-target='list']", action: :play),
        step(:conteo_confirm, company_night_attendance_path(practice_company, genero: @participant.gender, practica: "1"),
             target: "[data-night-attendance-target='confirm']", action: :practice)
      ]
    end

    def alert_steps
      return [] unless @user.alert_manager?

      [
        step(:alert_form, new_alert_path, target: "[data-tour='audience']"),
        step(:alert_send, new_alert_path, target: "#alert-form button[type='submit']", action: :practice)
      ]
    end

    def center_key
      @user.global_searcher? ? :center_search : :center_qr
    end

    def practice_company
      return @practice_company if defined?(@practice_company)

      @practice_company = @participant.practice_company
    end

    def role_notes
      { "consejero" => "consejeros", "auxiliar" => "auxiliares", "logistica" => "logística",
        "director_logistica" => "logística" }.fetch(@participant.rol, "cada rol")
    end
end
