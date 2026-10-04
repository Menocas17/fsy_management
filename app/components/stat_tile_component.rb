# frozen_string_literal: true

# Una cifra con su etiqueta. :lg es la que abre un módulo: tarjeta con mosaico sólido y cifra grande (en el
# teléfono se apila y se achica para que quepan tres en fila). :sm es una cifra de apoyo dentro de una tarjeta:
# bloque de lienzo con mosaico teñido. Con href, toda la tarjeta lleva a esa página.
class StatTileComponent < ViewComponent::Base
  def initialize(value:, label:, icon:, tone: :primary, size: :lg, href: nil, hint: nil, data: {})
    @value = value
    @label = label
    @icon = icon
    @tone = tone
    @size = size
    @href = href
    @hint = hint
    @data = data
  end

  private
    def large? = @size == :lg

    def wrapper_classes
      if large?
        helpers.card_classes("flex flex-col items-start gap-2.5 p-3.5 md:flex-row md:items-center md:gap-4 md:px-5 md:py-[18px]#{" transition-colors hover:bg-canvas dark:hover:bg-slate-700/40" if @href}")
      else
        "flex items-center gap-3 p-3.5 rounded-tile bg-canvas dark:bg-slate-800/60"
      end
    end
end
