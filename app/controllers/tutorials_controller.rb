# El tutorial (ver Tutorial). Empezarlo le manda a la persona su alerta de bienvenida, con la que practica
# borrar, y devuelve los pasos que le tocan; terminarlo o saltarlo lo deja como visto en su cuenta.
# En «Ver como» el superadmin lo recorre como vista previa: no le deja la alerta ni le marca el tutorial a la
# otra persona.
class TutorialsController < ApplicationController
  # El joven tiene el suyo (Tutorial#joven_steps).
  allow_jovenes
  before_action :require_tutorial
  skip_before_action :block_writes_while_viewing_as

  def create
    Tutorial.welcome_alert_for(Current.user) unless Current.viewing_as?
    render json: { steps: Tutorial.new(Current.user, preview: Current.viewing_as?).steps }
  end

  def update
    Tutorial.finish!(Current.user) unless Current.viewing_as?
    head :no_content
  end

  private
    def require_tutorial
      head :forbidden unless Tutorial.available_to?(Current.user)
    end
end
