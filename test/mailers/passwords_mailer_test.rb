require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  setup do
    @user = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan))
  end

  test "the invitation carries the link, its validity and the mark inline" do
    mail = PasswordsMailer.invitation(@user, reason: :new)

    assert_equal [ "juan@fsy.com" ], mail.to
    assert_match "Bienvenido a #{Rails.configuration.x.event_name}", mail.html_part.body.to_s
    assert_match "El enlace vale 7 días", mail.html_part.body.to_s
    assert_match "bienvenida=1", mail.text_part.body.to_s
    assert mail.attachments["fsy-mark.png"].inline?
  end

  test "the reset says how long the link lasts, in Spanish" do
    mail = PasswordsMailer.reset(@user)

    [ mail.html_part, mail.text_part ].each do |part|
      assert_match "El enlace vale 15 minutos", part.body.to_s
      assert_no_match(/Translation missing/, part.body.to_s)
    end
  end

  test "the SMTP check stays plain text, without the mark" do
    mail = SmtpCheckMailer.check("prueba@fsy.com")

    assert_empty mail.attachments
    assert_equal "text/plain", mail.mime_type
  end
end
