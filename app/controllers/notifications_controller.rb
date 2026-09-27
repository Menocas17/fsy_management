class NotificationsController < ApplicationController
  def index
    scope = Alert.visible_to(Current.user&.participant)
    @pagy, @alerts = pagy(scope.includes(images_attachments: :blob).recent)
    Current.user&.update_column(:alerts_read_at, Time.current)
  end

  # Lo consulta la campanita al volver atrás: el HTML cacheado trae el contador de antes de leerlas.
  def count
    render json: { unread: Current.user&.unread_alerts_count.to_i }
  end
end
