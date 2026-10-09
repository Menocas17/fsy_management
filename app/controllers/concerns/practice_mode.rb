# El tutorial practica sobre las páginas reales. Dos cosas lo hacen seguro:
#
# - Los jóvenes de práctica (Participant.practice_jovenes) solo se cargan con ?practica=1, como si fueran de la
#   compañía de quien hace el tutorial. Fuera de eso no existen (default_scope), así que ninguna escritura
#   puede tocarlos: avisar a enfermería o pasar el Conteo con uno de ellos no encuentra al joven.
# - Lo que el tutorial deja practicar sobre registros reales (borrar una capacitación, enviar una alerta) lleva
#   tutorial_practice=1 (tour_controller.js lo agrega, además de frenar el envío en el teléfono): el servidor
#   lo descarta sin ejecutar la acción.
module PracticeMode
  extend ActiveSupport::Concern

  included do
    helper_method :practice_mode?, :practice_link_params
    before_action :discard_practice_write, if: -> { params[:tutorial_practice].present? && !request.get? }
  end

  private
    def practice_mode?
      params[:practica] == "1" && practice_company.present?
    end

    def practice_company
      return @practice_company if defined?(@practice_company)

      @practice_company = Current.user&.participant&.practice_company
    end

    def practice_participant(id)
      return unless practice_mode?

      Participant.practice_jovenes_for(practice_company).find { |participant| participant.id == id.to_s }
    end

    # Para seguir en práctica al pasar de una página a otra con un joven de práctica.
    def practice_link_params(participant)
      participant&.practice? ? { practica: "1" } : {}
    end

    def discard_practice_write
      redirect_back_or_to dashboard_path, notice: "Práctica del tutorial: no se guardó nada."
    end
end
