require "test_helper"

class AppsScriptDeliveryTest < ActiveSupport::TestCase
  URL = "https://script.google.com/macros/s/abc/exec".freeze

  setup do
    @user = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan))
    @requests = []
  end

  test "posts the invitation with both bodies and the mark inline, renamed to a simple cid" do
    delivery = delivery_returning(response(Net::HTTPOK, { ok: true }.to_json))
    mail = PasswordsMailer.invitation(@user, reason: :new)

    delivery.deliver!(mail)

    verb, uri, body = @requests.sole
    payload = JSON.parse(body)
    assert_equal [ :post, URL ], [ verb, uri.to_s ]
    assert_equal "secreto", payload["secret"]
    assert_equal "juan@fsy.com", payload["to"]
    assert_equal mail.subject, payload["subject"]
    assert_equal Rails.configuration.x.event_name, payload["name"]
    assert_match "bienvenida=1", payload["text"]
    assert_match 'src="cid:img0"', payload["html"]
    assert_equal [ "img0", "image/png" ], payload["inline"].sole.values_at("cid", "mime")
    assert_equal Rails.root.join("app/assets/images/fsy-mark.png").binread, Base64.strict_decode64(payload["inline"].sole["data"])
  end

  test "a plain text mail goes without html nor images" do
    payload = delivery_returning.payload(SmtpCheckMailer.check("prueba@fsy.com"))

    assert_match "ya puede mandar correos", payload[:text]
    assert_nil payload[:html]
    assert_empty payload[:inline]
  end

  test "follows Google's redirect to read the answer" do
    redirect = response(Net::HTTPFound, "")
    redirect["location"] = "https://script.googleusercontent.com/macros/echo?id=1"
    delivery = delivery_returning(redirect, response(Net::HTTPOK, { ok: true }.to_json))

    delivery.deliver!(SmtpCheckMailer.check("prueba@fsy.com"))

    assert_equal [ :post, :get ], @requests.map(&:first)
    assert_equal "https://script.googleusercontent.com/macros/echo?id=1", @requests.last[1].to_s
  end

  test "raises with the script's error so the job fails visibly" do
    delivery = delivery_returning(response(Net::HTTPOK, { ok: false, error: "clave incorrecta" }.to_json))

    error = assert_raises(AppsScriptDelivery::Error) { delivery.deliver!(SmtpCheckMailer.check("prueba@fsy.com")) }
    assert_match "clave incorrecta", error.message
  end

  test "raises when Google answers a login page instead of JSON" do
    delivery = delivery_returning(response(Net::HTTPOK, "<html>Iniciar sesión</html>"))

    error = assert_raises(AppsScriptDelivery::Error) { delivery.deliver!(SmtpCheckMailer.check("prueba@fsy.com")) }
    assert_match "Cualquier persona", error.message
  end

  test "raises on an HTTP error" do
    delivery = delivery_returning(response(Net::HTTPInternalServerError, "boom"))

    assert_raises(AppsScriptDelivery::Error) { delivery.deliver!(SmtpCheckMailer.check("prueba@fsy.com")) }
  end

  test "refuses to send without url or secret" do
    delivery = AppsScriptDelivery.new(url: URL, secret: nil, transport: ->(*) { flunk "no debería pedir nada" })

    assert_raises(AppsScriptDelivery::Error) { delivery.deliver!(SmtpCheckMailer.check("prueba@fsy.com")) }
  end

  test "is registered as an Action Mailer delivery method" do
    assert_equal AppsScriptDelivery, ActionMailer::Base.delivery_methods[:apps_script]
  end

  private
    def delivery_returning(*responses)
      AppsScriptDelivery.new(url: URL, secret: "secreto", transport: lambda { |verb, uri, body|
        @requests << [ verb, uri, body ]
        responses.shift
      })
    end

    def response(klass, body)
      klass.new("1.1", "", "").tap do |response|
        response.instance_variable_set(:@body, body)
        response.instance_variable_set(:@read, true)
      end
    end
end
