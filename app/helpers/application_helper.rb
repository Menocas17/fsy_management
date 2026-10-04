module ApplicationHelper
  # Incluido aquí para que el super de #icon siempre lo encuentre, también fuera de las vistas (pruebas, jobs).
  include RailsIcons::Helpers::IconHelper

  ICON_CACHE = Concurrent::Map.new
  ICON_CACHE_LIMIT = 2_000

  # rails_icons lee el .svg del disco y lo pasa por Nokogiri en cada llamada (~0.15 ms), y una página dibuja
  # unas 70. Con los mismos argumentos el SVG sale idéntico, así que se arma una vez por proceso.
  # Un ícono que no existe no se guarda: sigue fallando igual.
  def icon(name, **options)
    return super if Rails.application.config.enable_reloading

    ICON_CACHE.clear if ICON_CACHE.size > ICON_CACHE_LIMIT
    ICON_CACHE.compute_if_absent([ name.to_s, options ]) { super.to_str.freeze }.html_safe
  end

  # Con un bucket público (R2_PUBLIC_URL) la imagen sale directo de Cloudflare: sin la redirección por Rails,
  # que en una página con 48 fotos eran 48 peticiones más al servidor. Si no hay bucket público, o la variante
  # aún no se procesó (key nil), queda la ruta de Active Storage, que la procesa al pedirla.
  def storage_url(attachable)
    base = Rails.configuration.x.public_storage_url
    key = attachable.key if base.present?
    key.present? ? "#{base}/#{key}" : attachable
  end

  # this helper creates a fallback using the ui-avatar api in case there is no image in the database, but the default is using an generic avatar image in case the api is not responding
  def avatar_for(participant, options = {})
    if participant.avatar.attached?
      image_tag(storage_url(participant.avatar.variant(:thumb)), options)
    elsif fallback_url = "https://ui-avatars.com/api/?name=#{participant.first_name}+#{participant.last_name}bold=true"
      image_tag(fallback_url, options)
    else
      image_tag("avatar-default.svg")
    end
  end
  # comment

  def check_notes (value)
    @value = value
    if @value || @value === ""
      @value
    else
      "No hay notas adicional por ahora"
    end
  end

  def check_if_na (value)
    @value = value
    if @value
      @value
    else
      "N/A"
    end
  end

  def submit_button_text(participant)
    if participant.new_record?
      "Crear"
    else
      "Actualizar"
    end
  end

  # Solo el color de la franja izquierda cambia por tipo; el resto del aviso sigue el tema.
  def toast_styles(type)
    case type.to_s
    when "notice" then "border-l-cat-green dark:border-l-cat-green"
    when "alert" then "border-l-cat-rose dark:border-l-cat-rose"
    else "border-l-primary-500 dark:border-l-primary-500"
    end
  end

  # options[:class] sets the size (and initials font size); the round shape and gradient fallback are always applied.
  def current_user_avatar_tag(options = {})
    size_classes = options[:class] || "w-9 h-9 text-body"
    participant = Current.user&.participant

    if participant&.avatar&.attached?
      image_tag storage_url(participant.avatar.variant(:thumb)), alt: "Tu foto de perfil", class: "#{size_classes} rounded-avatar object-cover shrink-0"
    else
      initials = participant&.full_name.to_s.split.map(&:first).first(2).join.upcase.presence || "FSY"

      content_tag(:span, initials, class: "#{size_classes} rounded-avatar shrink-0 bg-avatar-gradient text-white font-bold flex items-center justify-center")
    end
  end
end
