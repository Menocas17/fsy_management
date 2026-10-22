# Mientras dirección no abra las compañías (CompanyReveal), solo el acceso total ve compañías y jóvenes. El resto del
# staff no entra a la lista de jóvenes, sus fichas, las compañías, el conteo ni los cuartos, y vuelve a su inicio.
# El consejero tampoco a la lista del staff, las fichas ajenas, el organigrama, la búsqueda ni el escáner (ahí
# saldría su compañero(a)), y va a «Mi compañía», que se la muestra en cifras.
module CompanyRevealGate
  extend ActiveSupport::Concern

  HIDDEN_NOTICE = "Dirección todavía no abre las compañías: por ahora ves la tuya en cifras.".freeze
  STAFF_HIDDEN_NOTICE = "Dirección todavía no abre las compañías: hasta entonces solo las ve el acceso total.".freeze

  private
    # El tutorial (?practica=1) recorre la compañía y el conteo con jóvenes de práctica: ahí no hay nadie real.
    def company_hidden_here?
      Current.user&.company_hidden? && !practice_mode?
    end

    def require_company_revealed!
      return unless company_hidden_here?

      if Current.user.participant.consejero?
        redirect_to my_company_path, alert: HIDDEN_NOTICE
      else
        redirect_to dashboard_path, alert: STAFF_HIDDEN_NOTICE
      end
    end

    # Lo que solo se le cierra al consejero: ahí no hay jóvenes, pero sí quién es su compañero(a).
    def require_counselor_company_revealed!
      require_company_revealed! if Current.user&.counselor_company_hidden?
    end

    # El joven, hasta que se finaliza el registro (User#company_coming_soon?): su «Mi compañía» dice «Próximamente».
    def require_joven_company_open!
      redirect_to my_company_path, alert: "Tu compañía se abre cuando termine el registro." if Current.user&.company_coming_soon?
    end
end
