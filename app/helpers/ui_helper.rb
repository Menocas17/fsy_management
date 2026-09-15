module UiHelper
  CARD_CLASSES = "bg-surface dark:bg-slate-800 border border-line-soft dark:border-slate-700 rounded-[18px] shadow-md".freeze
  INPUT_CLASSES = "w-full h-10 px-3.5 rounded-[11px] bg-surface dark:bg-slate-900 border border-line dark:border-slate-600 text-[13.5px] text-ink-900 dark:text-slate-100 placeholder:text-ink-300 dark:placeholder:text-slate-500 focus:outline-none focus:ring-3 focus:ring-primary-500/15 focus:border-primary-500 disabled:cursor-not-allowed".freeze

  def card_classes(extra = nil)
    [ CARD_CLASSES, extra ].compact.join(" ")
  end

  def field_label_classes
    "block mb-1.5 text-[11.5px] font-bold text-ink-700 dark:text-slate-300"
  end

  def field_input_classes
    INPUT_CLASSES
  end

  def field_select_classes
    "#{INPUT_CLASSES} pr-9"
  end

  def field_textarea_classes
    INPUT_CLASSES.sub("h-10", "min-h-20 py-2.5 leading-relaxed resize-y")
  end

  def section_heading(title, icon_name)
    tag.div(class: "flex items-center gap-2.5 mb-4") do
      icon(icon_name, class: "w-[17px] h-[17px] text-primary-500 dark:text-primary-300") +
        tag.h2(title, class: "text-[11px] font-bold tracking-[.09em] uppercase text-primary-500 dark:text-primary-300")
    end
  end

  def info_row(label, icon_name, value)
    display = Array(value).compact_blank.join(" · ").presence || "—"
    tag.div(class: "flex items-start gap-3 py-3 first:pt-0 last:pb-0 border-t first:border-t-0 border-line-soft dark:border-slate-700") do
      tag.span(icon(icon_name, class: "w-4 h-4"),
               class: "w-[34px] h-[34px] shrink-0 rounded-[10px] flex items-center justify-center bg-primary-50 text-primary-600 dark:bg-primary-700/30 dark:text-primary-100") +
        tag.div(class: "min-w-0") do
          tag.p(label, class: "text-[11.5px] font-semibold text-ink-500 dark:text-slate-400") +
            tag.p(display, class: "mt-px text-[13.5px] font-semibold text-ink-900 dark:text-slate-100 break-words")
        end
    end
  end

  # Only same-site paths: a raw param in an href would allow javascript: URLs and open redirects.
  def safe_return_to(fallback)
    path = params[:return_to].to_s
    path.match?(%r{\A/(?![/\\])}) ? path : fallback
  end
end
