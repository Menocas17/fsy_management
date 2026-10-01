# Cambiar la contraseña desde adentro, confirmando la actual. No depende del correo, y cierra las demás
# sesiones de la cuenta: si alguien más la tenía abierta, ahí la pierde.
class PasswordChangesController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :update,
             with: -> { redirect_to edit_password_change_path, alert: "Intenta de nuevo más tarde." }

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if params[:password].blank?
      @user.errors.add(:password, :blank)
    # password_challenge siempre va (aunque venga vacío): sin la clave, Rails no verifica la actual.
    elsif @user.update(password: params[:password], password_confirmation: params[:password_confirmation].to_s,
                       password_challenge: params[:password_challenge].to_s)
      @user.sessions.where.not(id: Current.session.id).destroy_all
      return redirect_to settings_path, notice: "Tu contraseña se cambió. Se cerraron tus sesiones en otros dispositivos."
    end

    render :edit, status: :unprocessable_entity
  end
end
