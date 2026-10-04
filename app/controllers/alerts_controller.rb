class AlertsController < ApplicationController
  before_action :require_alert_manager!, only: %i[index new create destroy]
  before_action :set_alert, only: %i[show destroy]

  def index
    @pagy, @alerts = pagy(Alert.includes(sender: Participant::AVATAR_PRELOAD, images_attachments: :blob).recent)
  end

  def show
    redirect_to notifications_path, alert: "Esa alerta no está disponible" unless visible?(@alert)
  end

  def new
    @alert = Alert.new(priority: :informativa, audience: :todos)
  end

  def create
    @alert = Alert.new(alert_params)
    @alert.sender = Current.user&.participant
    # Same label the audit log uses for an account with no participant.
    @alert.sender_name = Current.user&.participant&.full_name || "Administrador del sistema"

    if @alert.save
      deliver_emails(@alert)
      # The alert records itself in Historial; see Alert#record_in_history.
      redirect_to alerts_path, notice: notice_for(@alert)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @alert.destroy
    record_audit!(category: :alertas, action: "destroyed", target: @alert, summary: "Eliminó la alerta «#{@alert.title}»")

    respond_to do |format|
      format.turbo_stream { render turbo_stream: removal_streams(@alert) }
      format.html { redirect_to alerts_path, status: :see_other, notice: "Alerta eliminada." }
    end
  end

  private
    def set_alert
      @alert = Alert.find(params[:id])
    end

    def visible?(alert)
      Alert.visible_to(Current.user&.participant).exists?(id: alert.id)
    end

    # La tarjeta ya se fue con la animación del deslizamiento; aquí se quita del DOM y se ajusta el total.
    def removal_streams(alert)
      remaining = Alert.count
      streams = [
        turbo_stream.remove_all("[data-alert-item='#{alert.id}']"),
        turbo_stream.update_all("[data-alerts-sent-total]", helpers.pluralize(remaining, "alerta enviada", plural: "alertas enviadas"))
      ]
      streams << turbo_stream.update_all("[data-alerts-sent-list]", partial: "alerts/empty_state") if remaining.zero?
      streams
    end

    def deliver_emails(alert)
      alert.email_recipients.find_each { |user| AlertsMailer.critical(user, alert).deliver_later }
    end

    def notice_for(alert)
      count = alert.email_recipients.count
      count.positive? ? "Alerta enviada. También se envió por correo a #{count} cuenta(s)." : "Alerta enviada."
    end

    def alert_params
      params.expect(alert: [ :title, :body, :audience, :priority, :send_email, { target_roles: [], images: [] } ])
    end
end
