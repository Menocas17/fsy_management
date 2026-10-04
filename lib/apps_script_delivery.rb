require "net/http"

# Método de entrega de Action Mailer que manda cada correo por HTTPS al Apps Script de
# docs/apps_script/mail_relay.gs (ver config/apps_script_mail.rb). Se registra como :apps_script en
# config/initializers/mail_delivery.rb.
#
# El script responde JSON ({ ok: true } o { ok: false, error: "…" }); cualquier otra cosa levanta Error,
# así el job de deliver_later falla en el log en vez de perder el correo en silencio.
class AppsScriptDelivery
  class Error < StandardError; end

  # Google contesta el POST con una redirección a script.googleusercontent.com, que es donde está la respuesta.
  MAX_REDIRECTS = 3

  attr_reader :settings

  # transport: lo que hace la petición, (método, URI, cuerpo) → Net::HTTPResponse. Solo los tests lo cambian.
  def initialize(settings)
    @settings = { transport: method(:http_request) }.merge(settings.to_h.symbolize_keys)
  end

  def deliver!(mail)
    raise Error, "Falta MAIL_RELAY_URL o MAIL_RELAY_SECRET (ver config/apps_script_mail.rb)" unless settings[:url].present? && settings[:secret].present?

    body = parse(post(settings[:url], payload(mail).to_json))
    raise Error, "El Apps Script no mandó el correo: #{body["error"].presence || body.inspect}" unless body["ok"] == true

    body
  end

  # Lo que recibe el script. Las imágenes en línea van en base64 con un cid simple (img0, img1…), porque
  # MailApp las busca por ese nombre en el HTML.
  def payload(mail)
    html = mail.html_part&.decoded || (mail.body.decoded if mail.mime_type == "text/html")
    text = mail.text_part&.decoded || (mail.body.decoded unless mail.multipart? || mail.mime_type == "text/html")

    inline = mail.attachments.select(&:inline?).each_with_index.map do |attachment, index|
      cid = "img#{index}"
      html = html&.gsub("cid:#{attachment.cid}", "cid:#{cid}")
      { cid: cid, mime: attachment.mime_type, data: Base64.strict_encode64(attachment.decoded) }
    end

    {
      secret: settings[:secret],
      to: Array(mail.to).join(","),
      cc: Array(mail.cc).join(",").presence,
      bcc: Array(mail.bcc).join(",").presence,
      reply_to: Array(mail.reply_to).join(",").presence,
      name: mail[:from]&.display_names&.first,
      subject: mail.subject,
      text: text,
      html: html,
      inline: inline
    }.compact
  end

  private
    def post(url, json)
      response = settings[:transport].call(:post, URI(url), json)
      MAX_REDIRECTS.times do
        break unless response.is_a?(Net::HTTPRedirection)
        response = settings[:transport].call(:get, URI(response["location"]), nil)
      end
      raise Error, "El Apps Script respondió HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def parse(body)
      JSON.parse(body.to_s)
    rescue JSON::ParserError
      # Si la web app no es pública ("Cualquier persona"), Google devuelve su página de inicio de sesión.
      raise Error, "El Apps Script no respondió JSON; ¿está publicado con acceso para «Cualquier persona»?"
    end

    def http_request(verb, uri, body)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 30) do |http|
        request = verb == :post ? Net::HTTP::Post.new(uri, "Content-Type" => "application/json") : Net::HTTP::Get.new(uri)
        request.body = body if body
        http.request(request)
      end
    end
end
