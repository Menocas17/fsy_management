# Mientras dirección no abra las compañías (CompanyReveal), el consejero no entra a las páginas donde verían los
# nombres de sus jóvenes o de su compañero(a): las listas, las fichas ajenas, las compañías, el organigrama, el
# conteo, los cuartos, la búsqueda y el escáner. Va a «Mi compañía», que se la muestra en cifras.
module CompanyRevealGate
  extend ActiveSupport::Concern

  HIDDEN_NOTICE = "Dirección todavía no abre las compañías: por ahora ves la tuya en cifras.".freeze

  private
    # El tutorial (?practica=1) recorre la compañía y el conteo con jóvenes de práctica: ahí no hay nadie real.
    def company_hidden_here?
      Current.user&.company_hidden? && !practice_mode?
    end

    def require_company_revealed!
      redirect_to my_company_path, alert: HIDDEN_NOTICE if company_hidden_here?
    end

    # El joven, hasta que se finaliza el registro (User#company_coming_soon?): su «Mi compañía» dice «Próximamente».
    def require_joven_company_open!
      redirect_to my_company_path, alert: "Tu compañía se abre cuando termine el registro." if Current.user&.company_coming_soon?
    end
end
