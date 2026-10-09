# El tutorial (ver Tutorial). Empezarlo le manda a la persona su alerta de bienvenida, con la que practica
# borrar, y devuelve los pasos que le tocan; terminarlo o saltarlo lo deja como visto en su cuenta.
# «Ver como» no lo usa: el superadmin no debe dejar la alerta ni marcar el tutorial de otra persona.
class TutorialsController < ApplicationController
  before_action :require_tutorial

  def create
    Tutorial.welcome_alert_for(Current.user)
    render json: { steps: Tutorial.new(Current.user).steps }
  end

  def update
    Tutorial.finish!(Current.user)
    head :no_content
  end

  private
    def require_tutorial
      head :forbidden if Current.viewing_as? || !Tutorial.available_to?(Current.user)
    end
end
