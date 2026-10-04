module ChartsHelper
  # Un color por dato, el mismo en los chips, en las gráficas y en cualquier pantalla: un rol o una estaca
  # no cambia de color al pasar del panel a la lista. Cada dato apunta a una categoría; la categoría tiene
  # su chip (clases de los tokens cat-* de application.css) y su hex para ApexCharts, que no entiende
  # OKLCH. Los hex son esos mismos tokens convertidos: si se cambia uno, se cambia el otro.
  # Las barras son relleno sólido (DESIGN.md, «regla de color»): estos hex son los tokens cat-*-solid.
  CATEGORY_HEX = {
    "blue" => "#0081b1", "indigo" => "#515bc3", "green" => "#298a41", "amber" => "#bb7400",
    "rose" => "#c03a51", "teal" => "#008687", "navy" => "#1d447c", "neutral" => "#6f757e"
  }.freeze
  CATEGORY_CHIP = {
    "blue" => "bg-cat-blue/15 text-cat-blue-ink",
    "indigo" => "bg-cat-indigo/15 text-cat-indigo-ink",
    "green" => "bg-cat-green/15 text-cat-green-ink",
    "amber" => "bg-cat-amber/20 text-cat-amber-ink",
    "rose" => "bg-cat-rose/15 text-cat-rose-ink",
    "teal" => "bg-cat-teal/15 text-cat-teal-ink",
    "navy" => "bg-primary-100 text-primary-700 dark:bg-primary-700/40 dark:text-primary-100",
    "neutral" => "bg-canvas text-ink-500 dark:bg-muted dark:text-ink-700"
  }.freeze

  ROLE_CATEGORY = {
    "joven" => "green", "consejero" => "amber", "auxiliar" => "blue", "coordinador" => "indigo",
    "director" => "navy", "logistica" => "rose", "director_logistica" => "teal"
  }.freeze
  STAKE_CATEGORY = { "bello_horizonte" => "blue", "las_americas" => "indigo", "villa_flor" => "green", "puerto_cabezas" => "amber" }.freeze
  GENDER_CATEGORY = { "H" => "blue", "M" => "rose" }.freeze

  # Etiquetas de la gráfica de roles; el orden sigue a los roles más numerosos.
  ROLE_CHART_LABELS = {
    "consejero" => "Consejero", "logistica" => "Logística", "auxiliar" => "Auxiliar", "coordinador" => "Coordinador",
    "director" => "Director", "director_logistica" => "Director de logística", "joven" => "Joven"
  }.freeze

  def self.chip(category)
    CATEGORY_CHIP.fetch(category.to_s, CATEGORY_CHIP["neutral"])
  end

  def self.hex(category)
    CATEGORY_HEX.fetch(category.to_s, CATEGORY_HEX["neutral"])
  end

  # La rampa del navy de la marca (primary-900 → primary-300), no un azul eléctrico aparte.
  AGE_SHADES = [ [ 0.9, "#07254f" ], [ 0.65, "#1d447c" ], [ 0.45, "#3671b2" ], [ 0.3, "#90b5dc" ] ].freeze
  AGE_LIGHTEST = "#dbeaf8".freeze

  def role_chart_label(role)
    ROLE_CHART_LABELS[role] || Participant.role_label(role)
  end

  def role_chart_color(role)
    ChartsHelper.hex(ROLE_CATEGORY[role])
  end

  # Acepta la clave del enum o su versión con título («Villa Flor»), que es como llegan los conteos.
  def stake_chart_color(stake)
    ChartsHelper.hex(STAKE_CATEGORY[stake.to_s.parameterize(separator: "_")])
  end

  def gender_chart_color(gender)
    ChartsHelper.hex(GENDER_CATEGORY[gender])
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
