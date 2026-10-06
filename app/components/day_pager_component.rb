# frozen_string_literal: true

# Las flechas para ir al día anterior o al siguiente (la agenda, la asistencia nocturna): en vez de un riel con
# todos los días, que no cabe en el teléfono. Sin href, la flecha queda apagada (no hay día antes o después).
# Los enlaces van con turbo_action replace: con turbo_refreshes_with morph la página se mezcla en su lugar.
class DayPagerComponent < ViewComponent::Base
  BUTTON = "inline-flex items-center justify-center w-9 h-9 rounded-control border border-line bg-surface text-ink-700 hover:bg-muted transition"
  DISABLED = "inline-flex items-center justify-center w-9 h-9 rounded-control border border-line-soft text-ink-500 dark:text-ink-300 cursor-not-allowed"

  def initialize(previous_href:, next_href:, previous_label: "Día anterior", next_label: "Día siguiente", data: {})
    @arrows = [ [ "chevron-left", previous_href, previous_label, "previous" ], [ "chevron-right", next_href, next_label, "next" ] ]
    @data = data
  end

  def call
    tag.div(class: "flex items-center gap-1.5 shrink-0", data: @data) do
      safe_join(@arrows.map { |glyph, href, label, direction| arrow(glyph, href, label, direction) })
    end
  end

  private
    def arrow(glyph, href, label, direction)
      symbol = helpers.icon(glyph, class: "w-4 h-4")
      if href
        helpers.link_to(symbol, href, class: BUTTON, aria: { label: label }, data: { turbo_action: "replace", day_pager: direction })
      else
        tag.span(symbol, class: DISABLED, aria: { hidden: true })
      end
    end
end
