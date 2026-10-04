# Cambiar la contraseña desde adentro, con la actual. Al guardarla se cierran las demás sesiones de la
# cuenta: si alguien más la tenía abierta, ahí la pierde.
class PasswordChangesController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :update,
             with: -> { redirect_to edit_password_change_path, alert: "Intenta de nuevo más tarde." }
  # En «Ver como» la cuenta es de otra persona: su contraseña no se toca desde aquí.
  before_action -> { redirect_to settings_path, alert: "Sal de «Ver como» para cambiar tu contraseña." if Current.viewing_as? }

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    # password_challenge siempre va (aunque venga vacío): sin la clave, Rails no verifica la actual.
    attributes = { password: params[:password], password_confirmation: params[:password_confirmation].to_s,
                   password_challenge: params[:password_challenge].to_s }

    if params[:password].blank?
      @user.errors.add(:password, :blank)
    elsif @user.update(attributes)
      @user.sessions.where.not(id: Current.session.id).destroy_all
      return redirect_to settings_path, notice: "Tu contraseña se cambió. Se cerraron tus sesiones en otros dispositivos."
    end

    render :edit, status: :unprocessable_entity
  end
end
