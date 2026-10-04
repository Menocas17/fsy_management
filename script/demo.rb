#!/usr/bin/env ruby
# Demo guiada de la app: abre Chrome (escritorio y teléfono, lado a lado), entra como superadmin y recorre lo
# que hace cada rol con «Ver como», sola, mientras alguien la va explicando. En pantalla un letrero dice qué
# se está mostrando y en la terminal sale el guion de cada escena.
#
# Solo mira: abre formularios, busca y filtra, pero no guarda nada, así que se puede correr contra producción.
#
#   bin/dev                                   # en otra terminal (o DEMO_URL apunta a producción)
#   bundle exec ruby script/demo.rb
#
# Variables:
#   DEMO_URL        http://localhost:3000 por defecto
#   DEMO_EMAIL      correo del superadmin (si falta, lo pregunta)
#   DEMO_PASSWORD   su contraseña (si falta, la pregunta sin mostrarla; nunca va en el repo)
#   DEMO_DEVICE     ambos (por defecto), escritorio o telefono
#   DEMO_ROLES      solo esos recorridos, p. ej. "consejero,auxiliar" (superadmin, director, coordinador,
#                   director_logistica, registrador, logistica, auxiliar, consejero)
#   DEMO_PACE       multiplica las pausas: 1.5 más lento, 0.5 más rápido
#   DEMO_PASOS=1    espera Enter antes de cada escena (para ir al ritmo de la explicación)
#   DEMO_HEADLESS=1 sin ventanas (para probar el guion)
#   DEMO_CAPTURAS   carpeta donde guardar una captura al final de cada escena
require "bundler/setup"
require "selenium-webdriver"
require "io/console"
require "fileutils"

module Demo
  PACE = Float(ENV.fetch("DEMO_PACE", "1"))
  BASE_URL = ENV.fetch("DEMO_URL", "http://localhost:3000").chomp("/")

  def self.pause(seconds)
    sleep(seconds * PACE)
  end

  # Una ventana de Chrome: el escritorio o el teléfono (emulado: ancho de iPhone, toque y su user agent).
  class Device
    PHONE = { width: 390, height: 844 }.freeze
    IPHONE_UA = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 " \
                "(KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1".freeze

    attr_reader :kind, :driver

    def initialize(kind)
      @kind = kind
      @driver = Selenium::WebDriver.for(:chrome, options: chrome_options)
      @caption = nil
    end

    def phone?
      kind == :telefono
    end

    def label
      phone? ? "Teléfono" : "Escritorio"
    end

    def place(x:, y:, width:, height:)
      driver.manage.window.position = Selenium::WebDriver::Point.new(x, y)
      driver.manage.window.size = Selenium::WebDriver::Dimension.new(width, height)
    end

    def screen
      driver.execute_script("return [window.screen.availWidth, window.screen.availHeight]")
    end

    def quit
      driver.quit
    rescue StandardError
      nil
    end

    # Navegación ---------------------------------------------------------------

    def visit(path)
      driver.navigate.to("#{BASE_URL}#{path}")
      settle
    end

    def path
      URI(driver.current_url).path
    end

    def sign_in(email, password)
      visit "/session/new"
      type_into find_css("input[name='email_address']"), email
      type_into find_css("input[name='password']"), password, slowly: false
      click find_css("form button[type='submit']")
      wait_until { path != "/session/new" || driver.page_source.include?("Intenta otro correo") }
      raise "No se pudo entrar: revisa DEMO_EMAIL y DEMO_PASSWORD." if path == "/session/new"
    end

    # Si la página se redibuja entre encontrar algo y tocarlo (Turbo), se vuelve a intentar.
    def self.retrying(*names)
      names.each do |name|
        original = instance_method(name)
        define_method(name) do |*args, **kwargs, &block|
          attempts = 0
          begin
            original.bind_call(self, *args, **kwargs, &block)
          rescue Selenium::WebDriver::Error::StaleElementReferenceError
            raise if (attempts += 1) > 2

            Demo.pause 0.6
            retry
          end
        end
      end
    end

    # Abre una opción del menú lateral (en el teléfono, desde el cajón). false si este rol no la tiene.
    def nav_to(text)
      phone? ? open_drawer : nil
      scope = phone? ? "//div[@id='mobile-menu']" : "//aside"
      link = find_xpath("#{scope}//nav//a[normalize-space()=#{xpath_literal(text)}]", wait: 2)
      unless link
        close_drawer if phone?
        note "#{text}: no está en el menú de este rol"
        return false
      end

      unless link.displayed?
        group = link.find_element(xpath: "./ancestor::div[@data-nav-group][1]/button")
        click group
        Demo.pause 0.4
      end
      click link
      true
    end

    def open_drawer
      3.times do
        trigger = find_css("button[aria-label='Abrir menú']", wait: 1)
        if trigger&.displayed?
          click trigger
          Demo.pause 0.6
          return
        end
        # En una página de detalle el teléfono cambia el menú por «‹ Volver».
        back = find_css("a[data-page-back-mobile]", wait: 1)
        back ? click(back) : break
      end
    end

    def close_drawer
      button = find_css("button[aria-label='Cerrar menú']", wait: 1)
      click button if button&.displayed?
    end

    def account_menu
      click find_css("button[aria-label='Menú de cuenta']")
      Demo.pause 0.6
    end

    # «Ver como» desde el menú de cuenta, como lo haría el superadmin.
    def view_as(role_label)
      account_menu
      button = find_xpath("//div[@data-view-as-roles]//button[normalize-space()=#{xpath_literal(role_label)}]")
      raise "No aparece «Ver como #{role_label}»: ¿la cuenta es la del superadmin?" unless button

      Demo.pause 0.5
      click button
    end

    def back_to_superadmin
      button = find_xpath("//*[@data-view-as-banner]//button", wait: 2)
      click button if button
    end

    # Acciones dentro de la página ---------------------------------------------

    # El primer enlace del contenido cuya dirección cumple el patrón (una ficha, una compañía…).
    def open_first(pattern, description)
      link = driver.find_elements(css: "main a[href]").find do |a|
        a.displayed? && URI(a.attribute("href")).path.match?(pattern)
      rescue URI::InvalidURIError
        false
      end
      return note("no hay #{description} para abrir") unless link

      click link
      true
    end

    def click_text(text, within: "main")
      element = find_xpath("//#{within}//*[self::a or self::button][normalize-space()=#{xpath_literal(text)}]", wait: 2)
      return note("no está «#{text}»") unless element&.displayed?

      click element
      true
    end

    def click_css(css, description = css)
      element = find_css(css, wait: 2)
      return note("no está #{description}") unless element&.displayed?

      click element
      true
    end

    retrying :nav_to, :open_drawer, :close_drawer, :account_menu, :view_as, :back_to_superadmin

    def search(text)
      field = find_css("main input[type='search'], main input[name='query']", wait: 2)
      return note("no hay buscador") unless field&.displayed?

      type_into field, text
      Demo.pause 1.5
      field.clear
      field.send_keys(" ", :backspace)
    end

    retrying :open_first, :click_text, :click_css

    def press_escape
      driver.action.send_keys(:escape).perform
      Demo.pause 0.4
    end

    # Baja por la página de a poco, como quien la va leyendo, y vuelve arriba.
    def tour_page(steps: 3, back_up: true)
      steps.times do
        driver.execute_script(<<~JS)
          const main = document.querySelector("main") || document.scrollingElement;
          main.scrollBy({ top: main.clientHeight * 0.6, behavior: "smooth" });
        JS
        Demo.pause 1.4
      end
      return unless back_up

      driver.execute_script('(document.querySelector("main") || document.scrollingElement).scrollTo({ top: 0, behavior: "smooth" })')
      Demo.pause 0.8
    end

    # El letrero de abajo: vive en <html>, fuera del <body> que Turbo reemplaza, y se repone tras cada carga.
    def caption(text)
      @caption = text
      paint_caption
    end

    def capture(title)
      dir = ENV["DEMO_CAPTURAS"]
      return if dir.to_s.empty?

      @shots = (@shots || 0) + 1
      FileUtils.mkdir_p(dir)
      name = format("%02d-%s-%s.png", @shots, kind, title.downcase.gsub(/[^a-z0-9]+/, "-").delete_suffix("-"))
      driver.save_screenshot(File.join(dir, name))
    end

    def note(text)
      puts "      · #{label}: #{text}"
      false
    end

    private
      def chrome_options
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument("--headless=new") if ENV["DEMO_HEADLESS"] == "1"
        options.add_argument("--no-first-run")
        options.add_argument("--no-default-browser-check")
        options.add_argument("--disable-search-engine-choice-screen")
        # El escáner de Registro pide la cámara: una de mentira, sin preguntar.
        options.add_argument("--use-fake-ui-for-media-stream")
        options.add_argument("--use-fake-device-for-media-stream")
        options.exclude_switches << "enable-automation"
        options.add_preference("credentials_enable_service", false)
        options.add_preference("profile.password_manager_enabled", false)
        options.add_preference("profile.password_manager_leak_detection", false)
        if phone?
          options.add_emulation(device_metrics: PHONE.merge(pixelRatio: 3, touch: true), user_agent: IPHONE_UA)
        end
        options
      end

      def click(element)
        highlight(element)
        element.click
        settle
      rescue Selenium::WebDriver::Error::ElementClickInterceptedError
        driver.execute_script("arguments[0].click()", element)
        settle
      end

      # Antes de cada clic, un aro alrededor de lo que se va a tocar: quien mira sigue el recorrido.
      def highlight(element)
        driver.execute_script(<<~JS, element)
          const el = arguments[0];
          el.scrollIntoView({ block: "center", behavior: "smooth" });
          el.style.transition = "box-shadow .2s";
          el.style.boxShadow = "0 0 0 3px #f5b301, 0 0 0 7px rgba(245,179,1,.35)";
          setTimeout(() => { el.style.boxShadow = ""; }, 900);
        JS
        Demo.pause 0.7
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        nil
      end

      def type_into(element, text, slowly: true)
        highlight(element)
        element.clear
        if slowly
          text.each_char { |char| element.send_keys(char); sleep(0.06 * PACE) }
        else
          element.send_keys(text)
        end
      end

      # Espera a que termine la visita de Turbo (html[aria-busy]) y a que la página esté cargada.
      def settle
        sleep [ 0.3 * PACE, 0.3 ].max
        wait_until(timeout: 15) do
          driver.execute_script('return document.readyState === "complete" && !document.documentElement.hasAttribute("aria-busy")')
        end
        paint_caption
        Demo.pause 0.5
      rescue Selenium::WebDriver::Error::TimeoutError
        nil
      end

      def paint_caption
        return unless @caption

        driver.execute_script(<<~JS, @caption, phone?)
          const [text, phone] = arguments;
          let box = document.getElementById("demo-caption");
          if (!box) {
            box = document.createElement("div");
            box.id = "demo-caption";
            box.style.cssText = "position:fixed;left:50%;transform:translateX(-50%);z-index:2147483647;" +
              "pointer-events:none;background:rgba(17,24,39,.92);color:#fff;font:600 " + (phone ? "12px" : "15px") +
              "/1.35 system-ui,sans-serif;padding:" + (phone ? "7px 12px" : "10px 18px") + ";border-radius:999px;" +
              "box-shadow:0 6px 24px rgba(0,0,0,.25);max-width:92vw;text-align:center;bottom:" + (phone ? "14px" : "22px");
            document.documentElement.appendChild(box);
          }
          box.textContent = text;
        JS
      rescue Selenium::WebDriver::Error::WebDriverError
        nil
      end

      def wait_until(timeout: 10, &block)
        Selenium::WebDriver::Wait.new(timeout: timeout, interval: 0.2).until(&block)
      end

      def find_css(css, wait: 8)
        wait_until(timeout: wait) { driver.find_elements(css: css).first }
      rescue Selenium::WebDriver::Error::TimeoutError
        nil
      end

      def find_xpath(xpath, wait: 8)
        wait_until(timeout: wait) { driver.find_elements(xpath: xpath).first }
      rescue Selenium::WebDriver::Error::TimeoutError
        nil
      end

      def xpath_literal(text)
        text.include?("'") ? %(concat('#{text.split("'").join(%q(', "'", '))}')) : "'#{text}'"
      end
  end

  # Los recorridos: por rol, escenas con lo que dice el letrero (title) y el guion para quien presenta (say).
  class Tour
    ROLE_LABELS = {
      "director" => "Director", "coordinador" => "Coordinador", "director_logistica" => "Director de logística",
      "registrador" => "Registrador", "logistica" => "Logística", "auxiliar" => "Auxiliar", "consejero" => "Consejero"
    }.freeze

    def initialize(devices, step_by_step:)
      @devices = devices
      @step_by_step = step_by_step
    end

    # Cada escena corre a la vez en todas las ventanas (un hilo por ventana); la siguiente empieza
    # cuando todas terminaron.
    def scene(title, say:, &block)
      if @step_by_step
        print "\n   ⏎  Enter para «#{title}»… "
        $stdin.gets
      end
      puts "\n▶ #{title}"
      puts "  #{say}"
      @devices.map { |device|
        Thread.new do
          device.caption(title)
          block.call(device)
          device.capture(title)
        rescue StandardError => e
          device.note("se saltó un paso (#{e.class.name.split("::").last}: #{e.message.lines.first&.strip})")
        end
      }.each(&:join)
      Demo.pause 0.8
    end

    def as(rol)
      label = ROLE_LABELS.fetch(rol)
      scene "Ver como · #{label}", say: "Con «Ver como» el superadmin ve exactamente el menú y los permisos de un #{label.downcase}." do |d|
        d.view_as(label)
      end
      yield
    end

    def superadmin
      scene "Superadmin · Panel de inicio", say: "El inicio: los indicadores del evento (jóvenes, staff, edades, estacas, tallas) en vivo." do |d|
        d.nav_to("Inicio")
        d.tour_page(steps: 4)
      end
      scene "Superadmin · Jóvenes", say: "La lista de jóvenes: búsqueda sin acentos, filtros y la ficha de cada uno." do |d|
        d.nav_to("Jóvenes")
        d.search("ma")
        d.open_first(record("participants"), "una ficha")
        d.tour_page(steps: 3)
      end
      scene "Superadmin · Ficha y QR", say: "Cada ficha tiene su código QR, el mismo del gafete: escanearlo abre esta ficha." do |d|
        d.click_css("[data-profile-qr]", "el botón del QR") && (Demo.pause(2) || d.press_escape)
      end
      scene "Superadmin · Staff", say: "El staff: consejeros, auxiliares, coordinación y logística, con sus filtros por rol." do |d|
        d.nav_to("Staff")
        d.tour_page(steps: 2)
      end
      scene "Superadmin · Compañías", say: "Las compañías con su personal (un hombre y una mujer por rol) y sus jóvenes." do |d|
        d.nav_to("Compañías")
        d.tour_page(steps: 2)
        d.open_first(record("companies"), "una compañía")
        d.tour_page(steps: 2)
      end
      scene "Superadmin · Organigrama", say: "El organigrama: dirección, coordinación, auxiliares y consejeros de un vistazo." do |d|
        d.nav_to("Organigrama")
        d.tour_page(steps: 2)
      end
      scene "Superadmin · Agenda", say: "La agenda del evento, con las capacitaciones y la asistencia." do |d|
        d.nav_to("Agenda")
        d.tour_page(steps: 2)
      end
      scene "Superadmin · Registro de llegadas", say: "El registro: se escanea el gafete y queda marcada la llegada, incluso sin internet." do |d|
        d.nav_to("Registro")
        Demo.pause 2
      end
      scene "Superadmin · Alertas", say: "Las alertas: avisos que llegan como notificación al teléfono de quien corresponde." do |d|
        d.nav_to("Alertas")
        d.tour_page(steps: 1)
      end
      scene "Superadmin · Logística", say: "Logística: las áreas del comité, el inventario y las finanzas con sus etapas de aprobación." do |d|
        d.nav_to("Áreas")
        d.tour_page(steps: 1)
        d.nav_to("Inventario")
        d.tour_page(steps: 1)
        d.nav_to("Finanzas")
        d.tour_page(steps: 2)
      end
      scene "Superadmin · Reportes", say: "Reportes en PDF listos para imprimir: listas, gafetes, etiquetas, y la carga masiva desde Excel." do |d|
        d.nav_to("Reportes")
        d.tour_page(steps: 2)
      end
      scene "Superadmin · Seguimiento", say: "La asistencia nocturna de todas las compañías y el historial de todo lo que se cambia, con quién y cuándo." do |d|
        d.nav_to("Asistencia nocturna")
        d.tour_page(steps: 1)
        d.nav_to("Historial")
        d.tour_page(steps: 2)
      end
      scene "Enfermería · Tablero en vivo", say: "Enfermería: un tablero en vivo de quién va en camino, quién está adentro y quién ya salió, con sus alergias a la vista." do |d|
        d.nav_to("Enfermería")
        d.tour_page(steps: 2)
      end
      scene "Enfermería · Ficha clínica", say: "La ficha clínica: notas, signos vitales y medicamentos, que se descuentan solos del inventario de enfermería. Nada se borra." do |d|
        d.open_first(record("enfermeria/fichas"), "una ficha clínica")
        d.tour_page(steps: 3)
      end
      scene "Enfermería · Ingresar a un joven", say: "Enfermería ingresa a un joven con el motivo; a sus consejeros y a su auxiliar les llega una alerta, sin el detalle médico." do |d|
        d.nav_to("Enfermería")
        d.click_text("Ingresar joven")
        d.tour_page(steps: 2)
      end
      scene "Superadmin · Menú de cuenta", say: "Desde la cuenta: configuración, mi perfil, accesos (quién está en línea) y «Ver como»." do |d|
        d.account_menu
        Demo.pause 2.5
        d.press_escape
      end
    end

    def director
      as "director" do
        scene "Director · Inicio y compañías", say: "El matrimonio director edita todo: ve el evento completo y cada compañía." do |d|
          d.tour_page(steps: 2)
          d.nav_to("Compañías")
          d.open_first(record("companies"), "una compañía")
          d.tour_page(steps: 2)
        end
        scene "Director · Reportes y asistencia", say: "Dirección imprime reportes y sigue la asistencia nocturna de todas las compañías." do |d|
          d.nav_to("Reportes")
          d.tour_page(steps: 1)
          d.nav_to("Asistencia nocturna")
          d.tour_page(steps: 1)
        end
      end
    end

    def coordinador
      as "coordinador" do
        scene "Coordinador · Su vista", say: "El coordinador también tiene acceso total: asigna auxiliares y consejeros a las compañías." do |d|
          d.nav_to("Organigrama")
          d.tour_page(steps: 2)
          d.nav_to("Staff")
          d.open_first(record("participants"), "una ficha")
          d.click_text("Editar")
          d.tour_page(steps: 3)
        end
      end
    end

    def director_logistica
      as "director_logistica" do
        scene "Director de logística · Su comité", say: "El director de logística arma las áreas y decide quién registra, quién lleva finanzas y quién enfermería." do |d|
          d.nav_to("Áreas")
          d.open_first(record("areas"), "un área")
          d.tour_page(steps: 2)
        end
        scene "Director de logística · Inventario y finanzas", say: "Configura el presupuesto, aprueba gastos y lleva el inventario con sus movimientos." do |d|
          d.nav_to("Inventario")
          d.open_first(record("inventario"), "un inventario")
          d.tour_page(steps: 1)
          d.nav_to("Finanzas")
          d.tour_page(steps: 2)
        end
        scene "Director de logística · Reportes e historial", say: "Ve los reportes de su sección y el historial de su comité." do |d|
          d.nav_to("Reportes")
          d.tour_page(steps: 1)
          d.nav_to("Historial")
          d.tour_page(steps: 1)
        end
      end
    end

    def registrador
      as "registrador" do
        scene "Registrador · Inscribir jóvenes", say: "El registrador inscribe y corrige jóvenes; no toca al staff." do |d|
          d.nav_to("Jóvenes")
          d.click_text("Nuevo participante")
          d.tour_page(steps: 3)
        end
        scene "Registrador · Registro de llegadas", say: "El día de llegada escanea gafetes desde el teléfono." do |d|
          d.nav_to("Registro")
          Demo.pause 2
        end
      end
    end

    def logistica
      as "logistica" do
        scene "Logística · Su menú", say: "Un miembro de logística ve solo lo suyo: el inventario y lo de su área (registro, finanzas o enfermería)." do |d|
          d.nav_to("Inventario")
          d.tour_page(steps: 1)
          d.nav_to("Registro") || d.nav_to("Finanzas") || d.nav_to("Enfermería")
          d.tour_page(steps: 1)
        end
      end
    end

    def auxiliar
      as "auxiliar" do
        scene "Auxiliar · Su rama", say: "El auxiliar edita las compañías de su rama, su personal y a sus jóvenes." do |d|
          d.nav_to("Compañías")
          d.open_first(record("companies"), "una compañía")
          d.tour_page(steps: 2)
        end
        scene "Auxiliar · Asistencia y enfermería", say: "Sigue la asistencia nocturna de su rama y ve el tablero de enfermería." do |d|
          d.nav_to("Asistencia nocturna")
          d.tour_page(steps: 1)
          d.nav_to("Enfermería")
          d.tour_page(steps: 1)
        end
      end
    end

    def consejero
      as "consejero" do
        scene "Consejero · Un menú limpio", say: "El consejero solo ve lo que puede usar: nada de módulos en gris." do |d|
          d.nav_to("Inicio")
          d.open_drawer if d.phone?
          Demo.pause 2.5
          d.close_drawer if d.phone?
        end
        scene "Consejero · Su compañía", say: "Ve a sus jóvenes, edita sus fichas y el nombre que eligió la compañía." do |d|
          d.nav_to("Compañías")
          d.open_first(record("companies"), "su compañía")
          d.tour_page(steps: 2)
        end
        scene "Consejero · Asistencia nocturna", say: "Cada noche pasa lista de su compañía desde el teléfono." do |d|
          d.nav_to("Asistencia nocturna")
          d.tour_page(steps: 2)
        end
        scene "Consejero · Lleva a un joven a enfermería", say: "Si un joven se siente mal, el consejero avisa «lo llevo»: enfermería lo ve venir en el tablero y confirma cuando llega." do |d|
          d.nav_to("Enfermería")
          d.click_text("Llevar a enfermería")
          d.tour_page(steps: 2)
        end
      end
    end

    # La ficha de un registro (los ids son UUID): /companies/<id>, no /companies/new ni /companies/overview.
    def record(prefix)
      %r{\A/#{prefix}/\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z}
    end

    ORDER = %w[superadmin director coordinador director_logistica registrador logistica auxiliar consejero].freeze

    def run(roles)
      (ORDER & roles).each { |rol| public_send(rol) }
      scene "Fin", say: "De vuelta a la vista del superadmin." do |d|
        d.back_to_superadmin
        d.nav_to("Inicio")
      end
    end
  end

  def self.ask(prompt, secret: false)
    print prompt
    answer = secret ? $stdin.noecho(&:gets).tap { puts } : $stdin.gets
    answer.to_s.strip
  end

  def self.run
    email = ENV["DEMO_EMAIL"].presence_in_demo || ask("Correo del superadmin: ")
    password = ENV["DEMO_PASSWORD"].presence_in_demo || ask("Contraseña: ", secret: true)
    roles = ENV.fetch("DEMO_ROLES", Tour::ORDER.join(",")).split(",").map(&:strip)
    kinds = case ENV.fetch("DEMO_DEVICE", "ambos")
    when "escritorio" then %i[escritorio]
    when "telefono", "teléfono" then %i[telefono]
    else %i[escritorio telefono]
    end

    devices = kinds.map { |kind| Device.new(kind) }
    arrange(devices)
    devices.map { |device| Thread.new { device.sign_in(email, password) } }.each(&:join)

    Tour.new(devices, step_by_step: ENV["DEMO_PASOS"] == "1").run(roles)
    puts "\nListo. Enter para cerrar las ventanas."
    $stdin.gets
  ensure
    devices&.each(&:quit)
  end

  # Escritorio a la izquierda y el teléfono a la derecha, llenando la pantalla.
  def self.arrange(devices)
    width, height = ENV["DEMO_HEADLESS"] == "1" ? [ 1800, 1000 ] : devices.first.screen
    phone_width = 430
    devices.each do |device|
      if device.phone?
        device.place(x: devices.one? ? 0 : width - phone_width, y: 0, width: phone_width, height: [ height, 960 ].min)
      else
        device.place(x: 0, y: 0, width: devices.one? ? width : width - phone_width, height: height)
      end
    end
  end
end

class String
  def presence_in_demo
    strip.empty? ? nil : self
  end
end

class NilClass
  def presence_in_demo
    nil
  end
end

Demo.run if $PROGRAM_NAME == __FILE__
