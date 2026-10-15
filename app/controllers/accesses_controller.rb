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
    @granted = User.where(full_access_granted: true).includes(:participant).order(:email_address)
    @grant_candidates = User.full_access_candidates
  end

  # Acceso total a dedo: excepciones puntuales que decide el superadmin, fuera de lo que da el rol.
  def grant_full_access
    user = User.full_access_candidates.find_by(id: params[:user_id])
    return redirect_to accesses_path(anchor: "acceso-total"), alert: "Elige una cuenta de staff sin acceso total." unless user

    user.update!(full_access_granted: true)
    record_audit!(category: :cuentas, action: "updated", target: user.participant,
                  summary: "Le dio acceso total a #{user.participant.full_name} (#{user.email_address})")
    redirect_to accesses_path(anchor: "acceso-total"), notice: "#{user.participant.full_name} ahora tiene acceso total."
  end

  def revoke_full_access
    user = User.where(full_access_granted: true).find(params[:id])
    user.update!(full_access_granted: false)
    record_audit!(category: :cuentas, action: "updated", target: user.participant,
                  summary: "Le quitó el acceso total a #{user.participant&.full_name || user.email_address}")
    redirect_to accesses_path(anchor: "acceso-total"), notice: "Se quitó el acceso total a #{user.participant&.full_name || user.email_address}."
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
