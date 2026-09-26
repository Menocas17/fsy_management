class AlertsMailer < ApplicationMailer
  # Critical alerts are the only ones that leave the app.
  def critical(user, alert)
    @user = user
    @alert = alert
    mail subject: "[FSY 2026] #{alert.title}", to: user.email_address
  end
end
