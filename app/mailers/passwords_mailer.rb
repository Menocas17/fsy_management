class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Restablece tu contraseña", to: user.email_address
  end

  # La cuenta recién creada (o restablecida desde la ficha): un enlace para elegir la contraseña, que vale
  # User::INVITATION_VALID_FOR. reason: :new o :reset, solo cambia el texto.
  def invitation(user, reason: :new)
    @user = user
    @reason = reason.to_sym
    @url = edit_password_url(user.invitation_token, bienvenida: (1 if @reason == :new))
    subject = @reason == :new ? "Tu cuenta de #{Rails.configuration.x.event_name}" : "Elige una contraseña nueva"
    mail subject: subject, to: user.email_address
  end
end
