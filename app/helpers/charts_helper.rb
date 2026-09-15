module ChartsHelper
  # ApexCharts can't parse OKLCH, so these are hex equivalents of the cat-* and primary-* theme tokens.
  CATEGORY_COLORS = %w[#0093c5 #5965cd #369e4e #dc932e #d14a5f].freeze

  ROLE_CHART = {
    "coordinador" => [ "Coordinador", "#5965cd" ],
    "consejero" => [ "Consejero", "#dc932e" ],
    "auxiliar" => [ "Auxiliar", "#369e4e" ],
    "logistica" => [ "Logística", "#90b5dc" ],
    "director" => [ "Director", "#1d447c" ],
    "director_logistica" => [ "Director de logística", "#255896" ],
    "registrador" => [ "Registrador", "#d14a5f" ],
    "joven" => [ "Joven", "#0093c5" ]
  }.freeze

  AGE_SHADES = [ [ 0.9, "#1d447c" ], [ 0.65, "#255896" ], [ 0.45, "#3671b2" ], [ 0.3, "#90b5dc" ] ].freeze
  AGE_LIGHTEST = "#c5d5e8".freeze

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
