# «Accesos»: quién está usando la app, sus sesiones abiertas y los intentos de entrar. Solo lo ve el
# superadmin, que es quien responde si alguien entra a una cuenta que no es suya.
class AccessesController < ApplicationController
  before_action :require_superadmin!

  def index
    @online = Session.online.includes(user: :participant).recent_first
    @sessions = Session.includes(user: :participant).recent_first.limit(100)
    @attempts = LoginAttempt.includes(user: :participant).recent
    @attempts = @attempts.where.not(result: :success) if params[:solo] == "fallidos"
    @attempts = @attempts.limit(150)
    @failed_today = LoginAttempt.where.not(result: :success).where(created_at: Date.current.all_day).count
  end

  # Cerrar una sesión la invalida en su dispositivo: en la próxima página le pide entrar de nuevo.
  def destroy_session
    session_record = Session.find(params[:id])
    session_record.destroy
    notice = session_record == Current.session ? "Cerraste tu propia sesión." : "Se cerró la sesión de #{session_record.user.email_address}."
    redirect_to accesses_path, notice: notice
  end

  private
    def require_superadmin!
      redirect_to dashboard_path, alert: "Solo el administrador del sistema ve los accesos." unless Current.user&.superadmin?
    end
end
