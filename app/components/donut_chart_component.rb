# frozen_string_literal: true

# Dona dibujada en el servidor (SVG), con el total en el hueco: la del inicio («Distribución por rol») no necesita
# ApexCharts. Cada parte es un arco del mismo círculo (stroke-dasharray), con una ranura entre una y otra que deja
# ver la tarjeta. Colores en hex (ChartsHelper).
class DonutChartComponent < ViewComponent::Base
  SIZE = 180
  THICKNESS = 27 # el hueco es el 70 % del diámetro, como la de antes
  GAP = 3

  def initialize(values:, colors:, label:, total: nil)
    @values = values
    @colors = colors
    @label = label
    @total = total
  end

  private
    def radius = (SIZE - THICKNESS) / 2.0
    def circumference = 2 * Math::PI * radius

    def arcs
      sum = @values.sum.to_f
      return [] unless sum.positive?

      gap = @values.count(&:positive?) > 1 ? GAP : 0
      offset = 0.0
      @values.each_with_index.filter_map do |value, index|
        next unless value.positive?

        length = circumference * value / sum
        arc = { color: @colors[index], dash: [ length - gap, 0.01 ].max.round(2), offset: (-offset).round(2) }
        offset += length
        arc
      end
    end
end
