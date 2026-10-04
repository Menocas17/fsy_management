module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :password_reset_emails?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
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
      return Current.session if Current.session

      Current.session = find_session_by_cookie
      Current.viewing_as = view_as_user if Current.session
      Current.session
    end

    # «Ver como» (ViewAsController): solo vale para el superadmin; si la ficha ya no existe, se olvida.
    def view_as_user
      participant_id = session[:view_as_participant_id]
      return if participant_id.blank?

      participant = Participant.find_by(id: participant_id) if Current.session.user.superadmin?
      return User.stand_in_for(participant) if participant

      session.delete(:view_as_participant_id)
      nil
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

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || dashboard_path
    end

    def start_new_session_for(user)
      session.delete(:view_as_participant_id)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      session.delete(:view_as_participant_id)
      cookies.delete(:session_id)
    end
end
