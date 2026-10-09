require "test_helper"

class SimpleModeTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(number: 7)
    participants(:juan).update!(company: @company)
    Membership.create!(associable: @company, participant: participants(:maria))
    @counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
  end

  test "the counselor gets the bottom bar with their company, their QR in the center and the rest in Más" do
    sign_in_as(@counselor)
    get dashboard_path

    assert_select "nav[data-bottom-nav]" do
      assert_select "a[data-bottom-nav-item='Inicio'][aria-current='page'][href='#{dashboard_path}']"
      assert_select "a[data-bottom-nav-item='Mi compañía'][href='#{company_path(@company)}']"
      assert_select "button[data-bottom-nav-item='Mi QR'][data-dialog-name='qr']"
      assert_select "a[data-bottom-nav-item='Agenda'][href='#{agenda_path}']"
      assert_select "[data-bottom-nav-item='Buscar']", false
    end
    assert_select "dialog[data-dialog-name='mas'] [data-more-items]" do
      assert_select "a[href='#{scan_path}']", text: /Escanear gafete/
      assert_select "a[href='#{participants_path}']", text: /Jóvenes/
      assert_select "a[href='#{dashboard_path}']", false
      assert_select "a[href='#{agenda_path}']", false
    end
    # Sin menú lateral en el teléfono: la barra lo reemplaza, y el cajón ni se dibuja.
    assert_select "button[aria-label='Abrir menú']", false
    assert_select "#mobile-menu", false
    assert_select "[data-controller~='mobile-menu']", false
  end

  test "the bottom bar's QR is asked for when its dialog opens, not drawn with every page" do
    sign_in_as(@counselor)
    get agenda_path

    frame = "turbo-frame##{ActionView::RecordIdentifier.dom_id(participants(:maria), :qr)}"
    assert_select "nav[data-bottom-nav] ~ dialog[data-dialog-name='qr'] #{frame}[loading='lazy'][src='#{participant_qr_path(participants(:maria))}']"
    assert_select "dialog[data-dialog-name='qr'] svg[role='img']", false

    get participant_qr_path(participants(:maria))
    assert_response :success
    assert_select "#{frame} svg[role='img']", 1
    assert_select "#{frame}", text: /#{participants(:maria).full_name}/
  end

  test "without simple mode the phone still gets its drawer" do
    @counselor.update!(simple_mode: false)
    sign_in_as(@counselor)
    get dashboard_path

    assert_select "#mobile-menu nav[aria-label='Navegación principal']"
    assert_select "[data-controller~='mobile-menu']"
  end

  test "the counselor's home shows their own figures, and two charts, without a way to the full dashboard" do
    sign_in_as(@counselor)
    get dashboard_path

    assert_select "[data-simple-kpis]" do
      assert_select "a[data-simple-kpi='Mis jóvenes']", text: /1\s*Mis jóvenes/
      assert_select "a[data-simple-kpi='Enfermería'][href='#{infirmary_visits_path}']", text: /0/ do
        assert_select "[data-kpi-badge]", text: "Ahora"
      end
      assert_select "[data-simple-kpi='Asistencia']", text: /Sin pasar/
    end
    assert_select "a[data-full-stats]", false
  end

  test "direction gets the search in the center and its QR inside Más" do
    director = participants(:maria).dup
    director.update!(rol: :director, first_name: "Rosa")
    sign_in_as(User.create!(email_address: "rosa@fsy.com", password: "Director1!", participant: director))
    get dashboard_path

    assert_select "a[data-bottom-nav-item='Buscar'][href='#{search_path}']"
    assert_select "a[data-bottom-nav-item='Compañías'][href='#{companies_path}']"
    assert_select "[data-bottom-nav-item='Mi QR']", false
    assert_select "dialog[data-dialog-name='mas'] button[data-dialog-name='qr']", text: /Mi QR/
    assert_equal [ "Mi QR", "Escanear gafete", "Alertas", "Enfermería", "Asistencia nocturna" ],
                 css_select("dialog[data-dialog-name='mas'] [data-more-items] > *").map { |item| item.text.squish }
    assert_select "[data-simple-kpi='Jóvenes']"
    assert_select "[data-simple-kpi='Staff']"
  end

  test "switching it off in Configuración brings back the side menu" do
    sign_in_as(@counselor)
    get settings_path
    assert_select "#settings-simple button[role='switch'][aria-checked='true']"

    patch simple_mode_settings_path, params: { simple_mode: "0" }
    assert_redirected_to settings_path(anchor: "settings-simple")
    assert_not @counselor.reload.simple_mode?

    get dashboard_path
    assert_select "nav[data-bottom-nav]", false
    assert_select "[data-simple-kpis]", false
    assert_select "button[aria-label='Abrir menú']"

    patch simple_mode_settings_path, params: { simple_mode: "1" }
    assert @counselor.reload.simple_mode?
  end

  test "jóvenes don't have it yet" do
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan)))

    get dashboard_path
    assert_select "nav[data-bottom-nav]", false

    get settings_path
    assert_select "#settings-simple", false
  end

  test "viewing as someone doesn't change their setting" do
    sign_in_as(users(:one))
    post view_as_path, params: { participant_id: participants(:maria).id }

    patch simple_mode_settings_path, params: { simple_mode: "0" }
    assert_redirected_to settings_path
    assert @counselor.reload.simple_mode?
  end
end
