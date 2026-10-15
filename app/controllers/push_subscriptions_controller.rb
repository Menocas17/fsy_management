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

  # «Enviar una prueba» en Configuración: un aviso de verdad, desde el servidor, a este dispositivo. Contesta qué
  # pasó, para saber si el problema está en el registro, en el servidor de push o en el teléfono.
  def send_test
    subscription = Current.user.push_subscriptions.find_by(endpoint: params[:endpoint])
    return render json: { error: "Este dispositivo no está registrado en el servidor." }, status: :not_found unless subscription

    message = { title: "Prueba de notificaciones",
                options: { body: "Si ves esto con la app cerrada, las alertas te van a llegar.", icon: "/icon-192.png",
                           badge: "/icon.png", tag: "push-test", data: { path: settings_path } } }
    error = PushNotificationJob.deliver(subscription, message, urgency: "high")
    return render json: { status: "ok" } unless error

    render json: { error: error }, status: :bad_gateway
  end

  def destroy
    Current.user.push_subscriptions.where(endpoint: params[:endpoint]).destroy_all
    head :no_content
  end
end
