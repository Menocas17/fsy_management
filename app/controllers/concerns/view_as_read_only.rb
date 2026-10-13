# «Ver como» solo mira. Viendo como otra persona, Current.user es esa persona: un gasto, una alerta, una nota de
# enfermería o un dispositivo para avisos quedaban a su nombre (y así el superadmin podía presentar un gasto y
# luego aprobarlo él mismo). Toda escritura se frena aquí; las pocas que son parte de mirar (salir de «Ver como»,
# cerrar sesión, el recorrido del tutorial, marcar leídas) se saltan este filtro en su controlador.
module ViewAsReadOnly
  extend ActiveSupport::Concern

  included do
    before_action :block_writes_while_viewing_as
  end

  private
    def block_writes_while_viewing_as
      return unless Current.viewing_as?
      return if request.get? || request.head?

      message = "Viendo como otra persona solo se mira: sal de «Ver como» para hacer cambios."
      respond_to do |format|
        format.html { redirect_back_or_to dashboard_path, alert: message }
        format.any { render json: { error: message }, status: :forbidden }
      end
    end
end
