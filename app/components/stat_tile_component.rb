# frozen_string_literal: true

# Una cifra con su etiqueta. :lg es la que abre un módulo: tarjeta con mosaico sólido y cifra grande (en el
# teléfono se apila y se achica para que quepan tres en fila). :sm es una cifra de apoyo dentro de una tarjeta:
# bloque de lienzo con mosaico teñido. Con href, toda la tarjeta lleva a esa página.
class StatTileComponent < ViewComponent::Base
  # data: va en la tarjeta (o el enlace); value_data:, en la cifra misma, para quien necesite leerla.
  # short_label: lo que se lee en el teléfono, donde tres mosaicos comparten fila y una etiqueta larga
  # («Miembros de logística») se partía en varias líneas y estiraba toda la fila.
  def initialize(value:, label:, icon:, tone: :primary, size: :lg, href: nil, hint: nil, data: {}, value_data: {}, short_label: nil)
    @value = value
    @label = label
    @icon = icon
    @tone = tone
    @size = size
    @href = href
    @hint = hint
    @data = data
    @value_data = { stat_value: true }.merge(value_data)
    @short_label = short_label
  end

  private
    def large? = @size == :lg

    def wrapper_classes
      if large?
        helpers.card_classes("flex flex-col items-start gap-2.5 p-3.5 md:flex-row md:items-center md:gap-4 md:px-5 md:py-[18px]#{" transition-colors hover:bg-canvas dark:hover:bg-muted/40" if @href}")
      else
        "flex flex-col items-start gap-2 md:flex-row md:items-center md:gap-3 p-3.5 rounded-tile bg-sunken#{" transition-colors hover:bg-line-soft/70 dark:hover:bg-muted/60" if @href}"
      end
    end
end
