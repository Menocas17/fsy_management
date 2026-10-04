require "rqrcode"

module UiHelper
  CARD_CLASSES = "bg-surface border border-line-soft rounded-card shadow-md".freeze
  INPUT_CLASSES = "w-full h-10 px-3.5 rounded-control bg-surface dark:bg-canvas border border-line text-body text-ink-900 placeholder:text-ink-300 focus:outline-none focus:ring-3 focus:ring-primary-500/15 focus:border-primary-500 disabled:cursor-not-allowed".freeze

  BUTTON_BASE = "inline-flex items-center justify-center gap-2 rounded-control text-sm font-semibold transition cursor-pointer " \
                "active:scale-[0.97] disabled:opacity-50 disabled:cursor-not-allowed disabled:active:scale-100".freeze
  BUTTON_SIZES = { sm: "h-9 px-3.5", md: "h-10 px-4", lg: "h-11 px-5" }.freeze
  BUTTON_VARIANTS = {
    primary: "bg-primary-700 text-white shadow-sm hover:bg-primary-800",
    secondary: "border border-line bg-surface text-ink-700 hover:bg-muted",
    danger: "bg-danger text-white shadow-sm hover:bg-danger/90",
    ghost: "text-ink-700 hover:bg-muted"
  }.freeze

  # Un solo lugar para los botones: antes cada vista copiaba su propia cadena y ninguna coincidía del todo.
  # extra suma lo que es del sitio (ancho, márgenes), no del botón.
  def button_classes(variant = :primary, size: :md, extra: nil)
    [ BUTTON_BASE, BUTTON_SIZES.fetch(size), BUTTON_VARIANTS.fetch(variant), extra ].compact.join(" ")
  end

  # Los filtros de una lista (shared/filter_sheet): el form los aplica solos y la hoja del teléfono lleva la
  # cuenta de cuántos hay puestos y se cierra con Esc.
  def filter_sheet_form_data(frame)
    { turbo_frame: frame, turbo_action: "advance", controller: "auto-submit filter-sheet",
      action: "change->filter-sheet#recount input->filter-sheet#recount keydown.esc@window->filter-sheet#close" }
  end

  # Un filtro dentro de la hoja: en el teléfono, su nombre encima; desde lg el envoltorio desaparece
  # (contents) y el campo queda suelto en la fila, donde el select ya dice qué filtra.
  def filter_field(label, id, &block)
    tag.div(class: "lg:contents") do
      label_tag(id, label, class: "lg:hidden mb-1 block text-label font-semibold text-ink-500") + capture(&block)
    end
  end

  # Unas iniciales en un mosaico, con el mismo algoritmo de color que los avatares: «C3» para la compañía 3,
  # la inicial de una compañía auxiliar. seed decide el color (el nombre), así cada una conserva el suyo.
  def initials_tile(text, seed:, size: :md)
    box = size == :sm ? "size-8 rounded-avatar-sm text-label" : "size-11 rounded-avatar text-body"
    tag.span(text, class: "#{box} shrink-0 flex items-center justify-center font-extrabold #{AvatarComponent.colors_for(seed)}",
                   data: { initials_tile: text })
  end

  def card_classes(extra = nil)
    [ CARD_CLASSES, extra ].compact.join(" ")
  end

  def field_label_classes
    "block mb-1.5 text-label font-bold text-ink-700"
  end

  def field_input_classes
    INPUT_CLASSES
  end

  # Las pantallas de acceso van siempre en claro y el formulario es todo el contenido: campos algo más altos.
  def auth_input_classes
    "w-full h-11 px-3.5 rounded-control bg-surface border border-line text-body text-ink-900 placeholder:text-ink-300 focus:outline-none focus:ring-3 focus:ring-primary-500/15 focus:border-primary-500"
  end

  def auth_button_classes
    "w-full inline-flex items-center justify-center gap-2 h-11 rounded-control bg-primary-700 text-sm font-semibold text-white shadow-md hover:bg-primary-800 transition cursor-pointer"
  end

  def field_select_classes
    "#{INPUT_CLASSES} pr-9"
  end

  def field_textarea_classes
    INPUT_CLASSES.sub("h-10", "min-h-20 py-2.5 leading-relaxed resize-y")
  end

  # QR en SVG, sin archivos intermedios: lo usan el inventario y las fichas de participante.
  def qr_svg_tag(payload, label:, size: 132, classes: nil)
    svg = RQRCode::QRCode.new(payload, level: :m).as_svg(
      module_size: 4, use_path: true, standalone: true, viewbox: true, color: "1D2B4A",
      svg_attributes: { role: "img", aria: { label: label } }
    )
    # La declaración XML que antepone rqrcode no va dentro de un documento HTML.
    tag.div(svg.sub(/\A<\?xml.*?\?>/, "").html_safe,
            class: [ "bg-white rounded-tile p-2.5 inline-block [&>svg]:block [&>svg]:w-full [&>svg]:h-auto", classes ].compact.join(" "),
            style: "width: #{size}px")
  end

  # Título de tarjeta en tipo de oración: las etiquetas en mayúsculas quedan solo para la barra superior.
  # El encabezado de sección de toda la aplicación (DESIGN.md): mosaico teñido de 34 px y título de 15. Lo que
  # vaya en el bloque (un conteo, un enlace) queda a la derecha.
  def section_heading(title, icon_name, tone: :primary, &block)
    tag.div(class: "flex items-center justify-between gap-3 mb-4", data: { section_heading: true }) do
      tag.div(class: "flex items-center gap-3 min-w-0") do
        render(IconTileComponent.new(icon: icon_name, tone: tone)) + tag.h2(title, class: "text-title font-bold text-ink-900")
      end + (block ? capture(&block) : "".html_safe)
    end
  end

  # href convierte el valor en enlace (p. ej. tel: para llamar desde la ficha); sin valor no hay enlace.
  # links: varios valores que llevan cada uno a su página, como [[nombre, ruta], …]; se unen con «y».
  def info_row(label, icon_name, value, href: nil, links: nil)
    display = Array(value).compact_blank.join(" · ").presence || "—"
    value_classes = "mt-px text-body font-semibold text-ink-900 [overflow-wrap:anywhere]"
    link_classes = "text-primary-700 dark:text-primary-300 underline decoration-primary-300/60 underline-offset-2 hover:decoration-primary-500"
    tag.div(class: "flex items-start gap-3 py-3 first:pt-0 last:pb-0 border-t first:border-t-0 border-line-soft") do
      tag.span(icon(icon_name, class: "w-4 h-4"),
               class: "w-[34px] h-[34px] shrink-0 rounded-control flex items-center justify-center bg-primary-50 text-primary-600 dark:bg-primary-700/30 dark:text-primary-100") +
        tag.div(class: "min-w-0") do
          tag.p(label, class: "text-label font-semibold text-ink-500") +
            if links.present?
              anchors = links.map { |text, path| link_to(text, path, class: link_classes) }
              tag.p(anchors.to_sentence(two_words_connector: " y ", last_word_connector: " y ").html_safe, class: value_classes)
            elsif href && display != "—"
              tag.p(link_to(display, href, class: link_classes), class: value_classes)
            else
              tag.p(display, class: value_classes)
            end
        end
    end
  end

  # Only same-site paths: a raw param in an href would allow javascript: URLs and open redirects.
  # La página actual, para mandarla como return_to en los enlaces a una página de detalle: así su botón de
  # volver regresa aquí. Las cadenas largas (perfil → compañía → perfil → …) se cortan a la dirección sola.
  def return_here
    path = request.fullpath
    path.length > 1500 ? request.path : path
  end

  def safe_return_to(fallback)
    path = params[:return_to].to_s
    path.match?(%r{\A/(?![/\\])}) ? path : fallback
  end
end
