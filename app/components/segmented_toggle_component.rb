# frozen_string_literal: true

# Las vistas de una misma página (Semana / Día / Capacitaciones, Activas / Todas): enlaces dentro de un riel,
# la opción actual en superficie con aria-current. Antes había tres copias a mano en agenda, capacitaciones y
# accesos. Cada item: { text:, href:, active:, icon: nil, data: {} }.
class SegmentedToggleComponent < ViewComponent::Base
  BASE = "inline-flex items-center gap-1.5 h-9 px-3.5 rounded-inner text-label whitespace-nowrap transition-colors"
  ACTIVE = "#{BASE} bg-surface dark:bg-muted shadow-sm font-bold text-ink-900".freeze
  IDLE = "#{BASE} font-semibold text-ink-500 hover:text-ink-900".freeze

  # floating: sobre un lienzo (el organigrama), el riel va en superficie con sombra en vez de hundido.
  RAIL = "inline-flex w-fit p-1 gap-0.5 rounded-control bg-canvas border border-line dark:border-line-soft"
  FLOATING_RAIL = "inline-flex w-fit p-1 gap-0.5 rounded-control bg-surface/95 border border-line-soft shadow-md"

  def initialize(label:, items:, floating: false)
    @label = label
    @items = items
    @floating = floating
  end

  def call
    tag.nav(class: @floating ? FLOATING_RAIL : RAIL, aria: { label: @label }) do
      safe_join(@items.map { |item| link_for(item) })
    end
  end

  private
    def link_for(item)
      helpers.link_to(item[:href], class: item[:active] ? ACTIVE : IDLE,
                                   aria: { current: ("page" if item[:active]) }, data: item.fetch(:data, {})) do
        safe_join([ (helpers.icon(item[:icon], class: "size-3.5") if item[:icon]), item[:text] ].compact)
      end
    end
end
