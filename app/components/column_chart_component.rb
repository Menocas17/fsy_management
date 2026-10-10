# frozen_string_literal: true

# Barras dibujadas en el servidor, con su número encima: las del inicio («Jóvenes por estaca») no necesitan
# ApexCharts, que en el teléfono pesaba ~130 KB y unos 100–200 ms de script en cada visita al inicio. Sin
# tooltip: el número ya está a la vista, también donde no hay mouse. Colores en hex (ChartsHelper).
class ColumnChartComponent < ViewComponent::Base
  # labels: un texto o un arreglo de líneas por barra («Puerto Cabezas» → ["Puerto", "Cabezas"]). height: el de las
  # barras; con sus etiquetas debajo, la tarjeta mide lo que medía la de ApexCharts de 220.
  def initialize(labels:, values:, colors:, label:, height: 176)
    @labels = labels
    @values = values
    @colors = colors
    @label = label
    @height = height
  end

  private
    def bars
      top = [ @values.max.to_i, 1 ].max
      @labels.each_with_index.map do |label, index|
        value = @values[index].to_i
        { lines: Array(label), value: value, ratio: (value.to_f / top).round(4), color: @colors[index] }
      end
    end
end
