# «Ver como»: el superadmin recorre la app con el menú y los permisos de otra persona, para probarla o
# presentarla sin cambiar de cuenta. Elige un rol (se toma una ficha que lo muestre bien,
# Participant.view_as_sample) o una ficha concreta desde su perfil. Mientras tanto solo mira: las escrituras
# las frena ViewAsReadOnly, para que nada quede a nombre de esa persona.
class ViewAsController < ApplicationController
  before_action :require_superadmin
  skip_before_action :block_writes_while_viewing_as

  def create
    participant = if params[:participant_id].present?
      Participant.where.not(rol: :joven).find_by(id: params[:participant_id])
    elsif Participant::VIEW_AS_ROLES.include?(params[:rol])
      Participant.view_as_sample(params[:rol])
    end
    return redirect_back_or_to(dashboard_path, alert: "No hay ninguna ficha con ese rol para ver la app como ella.") unless participant

    session[:view_as_participant_id] = participant.id
    redirect_to dashboard_path, notice: "Ahora ves la app como #{participant.full_name} (#{participant.role_label})."
  end

  def destroy
    session.delete(:view_as_participant_id)
    redirect_to dashboard_path, notice: "Volviste a tu vista de superadmin."
  end

  private
    def require_superadmin
      redirect_to dashboard_path, alert: "Solo el superadmin puede ver la app como otra persona." unless Current.real_user&.superadmin?
    end
end
