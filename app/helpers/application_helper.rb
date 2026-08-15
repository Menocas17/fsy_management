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
      "Crear Registro"
    else
      "Actualizar"
    end
  end

  def toast_styles(type)
    if type == "notice"
      "bg-[#EBF7EE] border border-[#CEEAD5]"
    elsif type == "alert"
      "bg-[#FCEDE9] border border-[#FAD8D6]"
    else
      "bg-[#E5EFF9] border border-[#CCE2F8]"
    end
  end

  def current_user_avatar_tag(options = {})
    css_classes = options[:class] || "w-[50px] h-[50px] rounded-full object-cover border-2 border-[#1C7DA5]"

    if Current.user&.participant&.avatar&.attached?
      image_tag Current.user.participant.avatar, class: css_classes
    else
      initials = Current.user&.participant&.full_name&.split&.map(&:first)&.join&.upcase || "FSY"

      content_tag(:div, initials, class: "#{css_classes} bg-blue-600 text-white flex items-center justify-center font-bold text-sm")
    end
  end
end
