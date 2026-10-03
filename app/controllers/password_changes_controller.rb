# Cambiar la contraseña desde adentro. Normalmente pide la actual; si la cuenta acaba de entrar con la
# predeterminada (must_change_password), no: la acaba de escribir y es la misma para todos. Al guardarla
# se cierran las demás sesiones de la cuenta: si alguien más la tenía abierta, ahí la pierde.
class PasswordChangesController < ApplicationController
  allow_pending_password_change
  rate_limit to: 10, within: 3.minutes, only: :update,
             with: -> { redirect_to edit_password_change_path, alert: "Intenta de nuevo más tarde." }

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    forced = @user.must_change_password?
    attributes = { password: params[:password], password_confirmation: params[:password_confirmation].to_s,
                   must_change_password: false }
    # password_challenge siempre va (aunque venga vacío): sin la clave, Rails no verifica la actual.
    attributes[:password_challenge] = params[:password_challenge].to_s unless forced

    if params[:password].blank?
      @user.errors.add(:password, :blank)
    elsif @user.update(attributes)
      @user.sessions.where.not(id: Current.session.id).destroy_all
      return redirect_to after_password_change_url(forced), notice: forced ? "Listo, ya tienes tu propia contraseña." : "Tu contraseña se cambió. Se cerraron tus sesiones en otros dispositivos."
    end

    @user.must_change_password = forced
    render :edit, status: :unprocessable_entity
  end

  private
    def after_password_change_url(forced)
      return settings_path unless forced

      session.delete(:return_to_after_password_change) || dashboard_path
    end
end
