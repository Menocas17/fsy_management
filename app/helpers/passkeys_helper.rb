module PasskeysHelper
  # La invitación a entrar con huella sale una sola vez, en la primera pantalla después de entrar con la
  # contraseña, y solo a quien todavía no tiene ninguna (el navegador además mira que el dispositivo la tenga).
  def passkey_offer?
    return false unless session.delete(:offer_passkey)

    !Current.viewing_as? && Current.user.passkeys.none?
  end
end
