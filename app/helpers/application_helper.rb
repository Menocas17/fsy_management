module ApplicationHelper
  # this helper creates a fallback using the ui-avatar api in case there is no image in the database, but the default is using an generic avatar image in case the api is not responding
  def avatar_for(participant, options = {})
    if participant.avatar.attached?
      image_tag(participant.avatar.variant(:thumb), options)
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
    size_classes = options[:class] || "w-9 h-9 text-[13px]"
    participant = Current.user&.participant

    if participant&.avatar&.attached?
      image_tag participant.avatar.variant(:thumb), alt: "Tu foto de perfil", class: "#{size_classes} rounded-avatar object-cover shrink-0"
    else
      initials = participant&.full_name.to_s.split.map(&:first).first(2).join.upcase.presence || "FSY"

      content_tag(:span, initials, class: "#{size_classes} rounded-avatar shrink-0 bg-avatar-gradient text-white font-bold flex items-center justify-center")
    end
  end
end
