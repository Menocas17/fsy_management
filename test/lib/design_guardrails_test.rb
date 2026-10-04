require "test_helper"

# Guarda de la guía de estilo (DESIGN.md): falla si una vista vuelve a traer lo que la unificación quitó.
# Cada excepción lleva su motivo; agregar una debería ser una decisión, no un atajo.
class DesignGuardrailsTest < ActiveSupport::TestCase
  ROOTS = %w[app/views app/components app/helpers app/javascript].freeze
  # Los correos se ven en clientes de correo, no en la app, y el layout trae su propio esqueleto.
  SKIP = %r{app/views/(layouts|.*_mailer)/}

  # Excepciones de DESIGN.md, «Colors»: la paleta de los avatares de iniciales.
  PALETTE_ALLOWED = %w[app/components/avatar_component.rb].freeze
  # El marco mismo, y pantallas a lo alto del lienzo (organigrama) o centradas a mano (mi perfil) con su relleno.
  FRAME_ALLOWED = %w[app/components/page_component.html.erb app/views/organigrama/_general.html.erb app/views/organigrama/_mine.html.erb app/views/participants/myprofile.html.erb].freeze
  # El banner de la cuenta regresiva queda fuera de la guía a propósito.
  TYPE_ALLOWED = %w[app/views/dashboards/show.html.erb].freeze

  PALETTE = /(?<![\w-])(?:[a-z0-9]+:)*(?:bg|text|border|ring|from|to|via|divide|outline|decoration|fill|stroke)-(?:slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-\d{2,3}\b/
  RADIUS = /(?<![\w-])(?:[a-z0-9]+:)*rounded(?:-[a-z]{1,2})?-(?:lg|xl|2xl|3xl)(?![\w-])/
  SHADOW = /(?<![\w-])(?:[a-z0-9]+:)*shadow-(?:xl|2xl)(?![\w-])/
  SMALL_TYPE = /(?<![\w-])(?:[a-z0-9]+:)*text-\[(\d+(?:\.\d+)?)px\]/
  OWN_FRAME = /class="px-4 md:px-8 pt-/
  ICON = /(?:\bicon\(?\s*|\bicon(?:_name)?:\s*|lucide_icon:\s*)"([a-z0-9-]+)"/

  test "colors come from the tokens, not the raw Tailwind palette" do
    assert_clean(PALETTE, except: PALETTE_ALLOWED, rule: "color suelto: usa los tokens (cat-*, ink-*, muted, sunken…)")
  end

  test "corners and shadows come from the tokens" do
    assert_clean(RADIUS, rule: "esquina genérica: usa rounded-control/inner/tile/card/panel/avatar")
    assert_clean(SHADOW, rule: "sombra fuera de la escala: solo shadow-sm, shadow-md y shadow-lg")
  end

  test "text uses the type scale" do
    offenders = scan(SMALL_TYPE, except: TYPE_ALLOWED).select { |_, _, match| match[1].to_f <= 22 }
    assert offenders.empty?, report(offenders, "tamaño suelto: usa text-meta/label/body/title/display (más de 22 px es arte, se permite)")
  end

  test "pages use the shared frame instead of their own wrapper and width" do
    assert_clean(OWN_FRAME, except: FRAME_ALLOWED, rule: "marco propio: usa PageComponent (width: :page o :form)")
  end

  test "every icon named in the views ships with the app" do
    available = Dir["app/assets/svg/icons/lucide/outline/*.svg"].map { |path| File.basename(path, ".svg") }.to_set
    missing = scan(ICON).reject { |_, _, match| available.include?(match[1]) }
    assert missing.empty?, report(missing, "ícono que no está en app/assets/svg/icons/lucide (rompe la página)")
  end

  private
    def files
      @files ||= ROOTS.flat_map { |root| Dir["#{root}/**/*.{erb,rb,js}"] }.reject { |path| path.match?(SKIP) }.sort
    end

    def scan(pattern, except: [])
      files.reject { |path| except.include?(path) }.flat_map do |path|
        File.readlines(path).each_with_index.flat_map do |line, index|
          line.to_enum(:scan, pattern).map { [ path, index + 1, Regexp.last_match ] }
        end
      end
    end

    def assert_clean(pattern, rule:, except: [])
      offenders = scan(pattern, except: except)
      assert offenders.empty?, report(offenders, rule)
    end

    def report(offenders, rule)
      "#{rule}\n" + offenders.first(25).map { |path, line, match| "  #{path}:#{line}  #{match[0]}" }.join("\n")
    end
end
