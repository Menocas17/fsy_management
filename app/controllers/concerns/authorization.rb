module Authorization
  extend ActiveSupport::Concern

  private
    def require_admin_to_create!
      unless Current.user&.admin_or_staff_manager?
        redirect_to dashboard_path, alert: "Acceso no autorizado"
      end
    end

  def authorize_admin_to_delete!
    unless Current.user&.admin_or_staff_manager?
      redirect_to participants_path, alert: "No estas autorizado para borrar registros"
    end
  end
end
