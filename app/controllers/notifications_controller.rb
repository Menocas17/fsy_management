class NotificationsController < ApplicationController
  def index
    @pagy, @alerts = pagy(Alert.inbox_for(Current.user).includes(images_attachments: :blob).recent)
    mark_read
  end

  # El menú de la campanita se abrió: lo que había quedó visto.
  def read
    mark_read
    head :no_content
  end

  # Las últimas alertas del menú de la campanita (escritorio). Llega como un turbo-frame perezoso: solo se pide
  # al abrir el menú, así ninguna otra página paga la consulta ni el dibujo de la lista.
  def menu
    @alerts = Alert.inbox_for(Current.user).recent.limit(5).to_a
    render partial: "shared/notifications_menu", locals: { alerts: @alerts }
  end

  # Lo consulta la campanita al volver atrás: el HTML cacheado trae el contador de antes de leerlas.
  def count
    render json: { unread: Current.user&.unread_alerts_count.to_i }
  end

  # Quita una alerta de la campanita de quien la borra; los demás la siguen viendo.
  def destroy
    alert = Alert.visible_to(Current.user.participant).find(params[:id])
    Current.user.alert_dismissals.find_or_create_by!(alert: alert)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: inbox_streams(removed: alert) }
      format.html { redirect_back_or_to notifications_path, status: :see_other }
    end
  end

  # Limpiar todo: lo que llegó hasta ahora se va; lo que llegue después aparece como siempre.
  def clear
    Current.user.update_column(:alerts_cleared_at, Time.current)
    Current.user.alert_dismissals.delete_all # ya no hacen falta: todo lo anterior quedó fuera

    respond_to do |format|
      format.turbo_stream { render turbo_stream: inbox_streams }
      format.html { redirect_back_or_to notifications_path, status: :see_other, notice: "Notificaciones limpias." }
    end
  end

  private
    # Viendo como otra persona, el superadmin no le marca nada como leído (y la ficha sin cuenta no tiene dónde).
    def mark_read
      Current.user&.update_column(:alerts_read_at, Time.current) unless Current.viewing_as?
    end

    # La misma alerta puede estar a la vez en la página y en el menú de la campanita: se actualizan los dos
    # en su lugar, sin reemplazar la campanita (cerraría el menú que la persona tiene abierto).
    def inbox_streams(removed: nil)
      remaining = Alert.inbox_for(Current.user).count
      unread = Current.user.unread_alerts_count

      streams = [ turbo_stream.update_all("[data-unread-count]", unread.positive? ? unread.to_s : "") ]
      streams << turbo_stream.remove_all("[data-alert-item='#{removed.id}']") if removed
      streams << turbo_stream.update_all("[data-alerts-total]", helpers.alerts_total_label(remaining))
      if remaining.zero?
        streams << turbo_stream.update_all("[data-alerts-list]", partial: "notifications/empty_state")
        streams << turbo_stream.remove_all("[data-alerts-when-any]")
      end
      streams
    end
end
