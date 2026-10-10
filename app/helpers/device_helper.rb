# Las listas que se ven distinto en la compu (tabla) y en el teléfono (tarjetas) armaban las dos versiones y el
# CSS escondía una: el doble de HTML que procesar en el teléfono. Chrome en Android dice que es un teléfono
# (Sec-CH-UA-Mobile: ?1) sin que se lo pidan, y entonces va solo la versión del teléfono. A la compu le siguen
# llegando las dos (una ventana angosta usa la del teléfono), igual que a Safari y Firefox, que no lo dicen.
module DeviceHelper
  def phone_hint?
    return @phone_hint if defined?(@phone_hint)

    response.headers["Vary"] = [ response.headers["Vary"].presence, "Sec-CH-UA-Mobile" ].compact.join(", ")
    @phone_hint = request.headers["Sec-CH-UA-Mobile"] == "?1"
  end

  def render_desktop_layout?
    !phone_hint?
  end

  # Las clases que reparten las dos versiones por ancho. Si va sola la del teléfono, se ve a todo ancho: un
  # teléfono acostado pasa de md y si no se quedaba sin lista.
  def layout_split(classes)
    phone_hint? ? "" : classes
  end
end
