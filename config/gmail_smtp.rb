# El correo sale por Gmail, con una cuenta dedicada a la app y una contraseña de aplicación (no la de la
# cuenta). Usuario y contraseña viven en las credenciales cifradas:
#
#   smtp:
#     user_name: la-cuenta@gmail.com
#     password: la contraseña de aplicación de 16 letras
#
# Gmail permite unos 500 destinatarios al día por cuenta. Lo usan production.rb y, si se pide,
# development.rb (SMTP_EN_DESARROLLO=1).
module GmailSmtp
  def self.settings
    {
      address: "smtp.gmail.com",
      port: 587,
      domain: "gmail.com",
      user_name: Rails.application.credentials.dig(:smtp, :user_name),
      password: Rails.application.credentials.dig(:smtp, :password),
      authentication: :plain,
      enable_starttls_auto: true,
      open_timeout: 10,
      read_timeout: 15
    }
  end

  def self.configured?
    settings.values_at(:user_name, :password).all?(&:present?)
  end
end
