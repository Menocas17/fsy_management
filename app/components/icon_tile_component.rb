# frozen_string_literal: true

# El mosaico cuadrado con un ícono: 34 px en encabezados de sección y cifras chicas, 40 en estados vacíos y
# 52 (sólido) en los mosaicos de cifra. Siempre con la esquina tile.
class IconTileComponent < ViewComponent::Base
  SIZES = {
    sm: [ "size-[34px]", "size-[17px]" ],
    md: [ "size-10", "size-[18px]" ],
    lg: [ "size-[52px]", "size-[22px]" ]
  }.freeze

  def initialize(icon:, tone: :primary, variant: :tint, size: :sm, classes: nil)
    @icon = icon
    @tone = tone
    @variant = variant
    @size = size
    @classes = classes
  end

  def call
    box, glyph = SIZES.fetch(@size)
    colors = @variant == :solid ? Tones.solid(@tone) : Tones.tint(@tone)
    tag.span(helpers.icon(@icon, class: glyph), aria: { hidden: true }, data: { icon_tile: @icon },
             class: [ box, "shrink-0 rounded-tile flex items-center justify-center", colors, @classes ].compact.join(" "))
  end
end
