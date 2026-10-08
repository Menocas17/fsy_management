require "net/http"
require "uri"

# Cliente HTTP mínimo para las pruebas de carga (script/carga/README.md): inicia sesión por el formulario real
# y guarda las cookies a mano. BASE_URL es la app (https://… en el droplet, http://127.0.0.1:3000 en local).
class Cliente
  BASE = URI(ENV.fetch("BASE_URL", "http://127.0.0.1:3000"))
  PASSWORD = ENV.fetch("PASSWORD") { abort "Falta PASSWORD (la de las cuentas de prueba)" }

  attr_reader :cookies

  # Con cookies, reusa la sesión de otro cliente: el inicio de sesión admite 10 intentos cada 3 minutos por IP.
  def initialize(email, cookies: nil)
    @cookies = cookies ? cookies.dup : {}
    @http = Net::HTTP.new(BASE.host, BASE.port)
    @http.use_ssl = BASE.scheme == "https"
    @http.keep_alive_timeout = 30
    @http.read_timeout = 120
    @http.start
    login(email) unless cookies
  end

  # [código HTTP, milisegundos, bytes]
  def get(path)
    request = Net::HTTP::Get.new(path)
    request["Cookie"] = cookie_header
    request["Accept"] = "text/html,application/json,application/pdf"
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = @http.request(request)
    elapsed = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000
    store(response)
    [ response.code.to_i, elapsed, response.body.to_s.bytesize ]
  end

  private
    def login(email)
      get("/session/new")
      token = @last_body[/name="csrf-token" content="([^"]+)"/, 1] or abort "La página de inicio de sesión no trajo el token CSRF"
      request = Net::HTTP::Post.new("/session")
      request["Cookie"] = cookie_header
      request.set_form_data("authenticity_token" => token, "email_address" => email, "password" => PASSWORD)
      response = @http.request(request)
      store(response)
      return if response.code == "302" && response["location"].to_s !~ /session/

      abort "No pudo entrar #{email} (#{response.code} → #{response['location']}). ¿Contraseña? ¿Más de 10 intentos en 3 minutos?"
    end

    def store(response)
      @last_body = response.body.to_s
      Array(response.get_fields("set-cookie")).each do |line|
        name, value = line.split(";").first.split("=", 2)
        @cookies[name] = value
      end
    end

    def cookie_header = @cookies.map { |k, v| "#{k}=#{v}" }.join("; ")
end
