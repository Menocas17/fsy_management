class SessionsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access only: %i[ new create ]
  before_action :redirect_if_authenticated, only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    LoginAttempt.record!(email: params[:email_address], result: :blocked, request: request)
    redirect_to new_session_path, alert: "Intenta de nuevo más tarde"
  }

  def new
  end

  def create
    # Una cuenta cuya ficha se borró no entra, aunque la contraseña sea la correcta.
    if (user = User.authenticate_by(params.permit(:email_address, :password))) && user.linked?
      LoginAttempt.record!(email: params[:email_address], result: :success, request: request, user: user)
      start_new_session_for user
      redirect_to after_authentication_url
    else
      LoginAttempt.record!(email: params[:email_address], result: :failed, request: request,
                           user: User.find_by(email_address: params[:email_address].to_s.strip.downcase))
      redirect_to new_session_path, alert: "Intenta otro correo o contraseña"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private
  def redirect_if_authenticated
    redirect_to dashboard_path if authenticated?
  end
end
