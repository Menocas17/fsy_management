# Guarda y borra el permiso que da cada navegador para recibir notificaciones.
# Habla JSON con el controlador Stimulus, no renderiza pantallas.
class PushSubscriptionsController < ApplicationController
  skip_forgery_protection only: :create, if: -> { request.headers["X-Service-Worker"].present? }

  def create
    subscription = params.require(:subscription)

    PushSubscription.register!(
      user: Current.user,
      endpoint: subscription[:endpoint],
      p256dh: subscription.dig(:keys, :p256dh),
      auth: subscription.dig(:keys, :auth),
      device: request.user_agent
    )

    render json: { status: "ok" }, status: :created
  rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing => error
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def destroy
    Current.user.push_subscriptions.where(endpoint: params[:endpoint]).destroy_all
    head :no_content
  end
end
