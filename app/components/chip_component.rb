# frozen_string_literal: true

# Categorías y estados: píldora de 24 px, letra label en negrita, tinte con su tinta. Gris para lo informativo.
class ChipComponent < ViewComponent::Base
  def initialize(label:, tone: :neutral, icon: nil, data: {})
    @label = label
    @tone = tone
    @icon = icon
    @data = data
  end

  def call
    tag.span(class: "inline-flex items-center gap-1 h-6 px-2.5 rounded-full text-label font-bold whitespace-nowrap #{Tones.tint(@tone)}",
             data: { chip: @tone }.merge(@data)) do
      safe_join([ (helpers.icon(@icon, class: "size-3.5") if @icon), @label ].compact)
    end
  end
end
