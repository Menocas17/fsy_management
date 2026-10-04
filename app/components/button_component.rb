# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(url: nil, text:, icon: nil, secondary_icon: nil, is_submit: false, is_delete: nil, is_button: nil, is_nav: nil, classes: nil, section: nil, method: nil, disabled: false, lucide_icon: nil, active_paths: [], except_paths: [], hint: nil)
    @url = url
    # Por qué está deshabilitado: «Próximamente» si todavía no existe, o quién tiene acceso si es por permiso.
    @hint = hint || "Próximamente"
    @disabled = disabled
    @lucide_icon = lucide_icon
    @active_paths = active_paths
    @except_paths = except_paths
    @text = text
    @icon = icon
    @is_submit = is_submit
    @classes = classes
    @is_delete = is_delete
    @is_button = is_button
    @secondary_icon = secondary_icon
    @is_nav = is_nav
    @section = section
    @method = method
  end

  # Solo lo usa el menú lateral (is_nav); las variantes de botón suelto se fueron con la guía de estilo:
  # los botones salen de button_classes.
  def styles
    [ "flex items-center gap-3 px-4 py-2.5 rounded-tile text-title font-semibold transition-colors duration-200", @classes ].compact.join(" ")
  end

  def disabled?
    @disabled
  end

  def active?
    helpers.nav_item_active?(url: @url, section: @section, active_paths: @active_paths,
                             except_paths: @except_paths, disabled: disabled?)
  end

  def active_classes
    # Activo: fondo azul claro con una barra de sol a la izquierda, para que se note de un vistazo.
    if active?
      "relative bg-primary-100/80 text-primary-700 shadow-sm dark:bg-primary-700/50 dark:text-white " \
        "before:absolute before:left-1 before:top-2 before:bottom-2 before:w-1 before:rounded-full before:bg-sun"
    else
      "text-ink-500 hover:bg-primary-50 hover:text-primary-700 dark:hover:bg-muted/60 dark:hover:text-ink-900"
    end
  end

  def current_icon
    active? ? @icon : @secondary_icon
  end
end
