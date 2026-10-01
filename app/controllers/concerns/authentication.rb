module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :require_password_change
    helper_method :authenticated?, :password_reset_emails?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end

    # Lo que sí se puede con la contraseña predeterminada pendiente de cambio: cambiarla y salir.
    def allow_pending_password_change(**options)
      skip_before_action :require_password_change, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def password_reset_emails?
      Rails.configuration.x.password_reset_emails
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    # Una sesión vencida (Session#expired?) o de una cuenta que perdió su ficha se cierra en vez de revivir;
    # si sigue viva, se anota que se usó (cada pocos minutos), que es lo que «Accesos» muestra como «en línea».
    def find_session_by_cookie
      session = Session.includes(:user).find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
      return unless session

      if session.expired? || !session.user.linked?
        session.destroy
        cookies.delete(:session_id)
        return
      end

      session.seen!
      session
    end

    # Quien entró con la contraseña predeterminada no hace nada más hasta cambiarla. Las páginas lo mandan a
    # cambiarla (y recuerdan a dónde iba); lo que no es una página (la campanita, el padrón) recibe un 403.
    def require_password_change
      return unless Current.user&.must_change_password?

      if request.format.html? || request.format.turbo_stream?
        session[:return_to_after_password_change] = request.url if request.get?
        redirect_to edit_password_change_path
      else
        head :forbidden
      end
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || dashboard_path
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
