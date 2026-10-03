require "rqrcode"

module UiHelper
  CARD_CLASSES = "bg-surface border border-line-soft rounded-card shadow-md".freeze
  INPUT_CLASSES = "w-full h-10 px-3.5 rounded-control bg-surface dark:bg-slate-900 border border-line text-[13.5px] text-ink-900 placeholder:text-ink-300 focus:outline-none focus:ring-3 focus:ring-primary-500/15 focus:border-primary-500 disabled:cursor-not-allowed".freeze

  BUTTON_BASE = "inline-flex items-center justify-center gap-2 rounded-control text-sm font-semibold transition cursor-pointer " \
                "active:scale-[0.97] disabled:opacity-50 disabled:cursor-not-allowed disabled:active:scale-100".freeze
  BUTTON_SIZES = { sm: "h-9 px-3.5", md: "h-10 px-4", lg: "h-11 px-5" }.freeze
  BUTTON_VARIANTS = {
    primary: "bg-primary-700 text-white shadow-sm hover:bg-primary-800",
    secondary: "border border-line bg-surface text-ink-700 hover:bg-canvas dark:hover:bg-slate-700",
    danger: "bg-danger text-white shadow-sm hover:bg-danger/90",
    ghost: "text-ink-700 hover:bg-canvas dark:hover:bg-slate-700"
  }.freeze

  # Un solo lugar para los botones: antes cada vista copiaba su propia cadena y ninguna coincidía del todo.
  # extra suma lo que es del sitio (ancho, márgenes), no del botón.
  def button_classes(variant = :primary, size: :md, extra: nil)
    [ BUTTON_BASE, BUTTON_SIZES.fetch(size), BUTTON_VARIANTS.fetch(variant), extra ].compact.join(" ")
  end

  def card_classes(extra = nil)
    [ CARD_CLASSES, extra ].compact.join(" ")
  end

  def field_label_classes
    "block mb-1.5 text-[11.5px] font-bold text-ink-700"
  end

  def field_input_classes
    INPUT_CLASSES
  end

  # Las pantallas de acceso van siempre en claro y el formulario es todo el contenido: campos algo más altos.
  def auth_input_classes
    "w-full h-11 px-3.5 rounded-control bg-surface border border-line text-[13.5px] text-ink-900 placeholder:text-ink-300 focus:outline-none focus:ring-3 focus:ring-primary-500/15 focus:border-primary-500"
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
            class: [ "bg-white rounded-xl p-2.5 inline-block [&>svg]:block [&>svg]:w-full [&>svg]:h-auto", classes ].compact.join(" "),
            style: "width: #{size}px")
  end

  # Título de tarjeta en tipo de oración: las etiquetas en mayúsculas quedan solo para la barra superior.
  def section_heading(title, icon_name)
    tag.div(class: "flex items-center gap-2.5 mb-4") do
      icon(icon_name, class: "w-[17px] h-[17px] text-primary-500 dark:text-primary-300") +
        tag.h2(title, class: "text-[15px] font-bold text-ink-900")
    end
  end

  # href convierte el valor en enlace (p. ej. tel: para llamar desde la ficha); sin valor no hay enlace.
  def info_row(label, icon_name, value, href: nil)
    display = Array(value).compact_blank.join(" · ").presence || "—"
    value_classes = "mt-px text-[13.5px] font-semibold text-ink-900 [overflow-wrap:anywhere]"
    tag.div(class: "flex items-start gap-3 py-3 first:pt-0 last:pb-0 border-t first:border-t-0 border-line-soft") do
      tag.span(icon(icon_name, class: "w-4 h-4"),
               class: "w-[34px] h-[34px] shrink-0 rounded-control flex items-center justify-center bg-primary-50 text-primary-600 dark:bg-primary-700/30 dark:text-primary-100") +
        tag.div(class: "min-w-0") do
          tag.p(label, class: "text-[11.5px] font-semibold text-ink-500") +
            if href && display != "—"
              tag.p(link_to(display, href, class: "text-primary-700 dark:text-primary-300 underline decoration-primary-300/60 underline-offset-2 hover:decoration-primary-500"), class: value_classes)
            else
              tag.p(display, class: value_classes)
            end
        end
    end
  end

  # Only same-site paths: a raw param in an href would allow javascript: URLs and open redirects.
  def safe_return_to(fallback)
    path = params[:return_to].to_s
    path.match?(%r{\A/(?![/\\])}) ? path : fallback
  end
end
