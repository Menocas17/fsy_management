module ChartsHelper
  # Paleta "Viva": saturada y con los tonos bien separados entre sí, que es lo que hace distinguible una
  # barra de la otra. Van en hexadecimal porque ApexCharts no entiende OKLCH.
  CATEGORY_COLORS = %w[#2563ff #7c3aed #00b878 #ff9500 #ff3b6b].freeze

  # Cada rol conserva su color en todas las pantallas; el orden sigue a los roles más numerosos.
  ROLE_CHART = {
    "consejero" => [ "Consejero", "#2563ff" ],
    "logistica" => [ "Logística", "#7c3aed" ],
    "auxiliar" => [ "Auxiliar", "#00b878" ],
    "coordinador" => [ "Coordinador", "#ff9500" ],
    "director" => [ "Director", "#ff3b6b" ],
    "director_logistica" => [ "Director de logística", "#00c2d7" ],
    "registrador" => [ "Registrador", "#facc15" ],
    "joven" => [ "Joven", "#38bdf8" ]
  }.freeze

  AGE_SHADES = [ [ 0.9, "#123fb8" ], [ 0.65, "#2563ff" ], [ 0.45, "#5586ff" ], [ 0.3, "#8fb0ff" ] ].freeze
  AGE_LIGHTEST = "#c9d8ff".freeze

  def role_chart_label(role)
    ROLE_CHART.dig(role, 0) || Participant.role_label(role)
  end

  def role_chart_color(role)
    ROLE_CHART.dig(role, 1) || "#b4b8be"
  end

  # The busiest ages get the darkest bars, like the design mockup.
  def age_bar_colors(counts)
    max = counts.max.to_f
    counts.map do |count|
      ratio = max.zero? ? 0 : count / max
      AGE_SHADES.find { |threshold, _| ratio >= threshold }&.last || AGE_LIGHTEST
    end
  end

  # Text alternative for screen readers, since the chart itself is an SVG drawn client-side.
  def chart_summary(labels, values)
    labels.zip(values).map { |label, value| "#{Array(label).join(' ')}: #{value}" }.join(", ")
  end
end
