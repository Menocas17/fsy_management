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
    assert_equal [ "Escanear gafete", "Conteo", "Organigrama", "Enfermería", "Compañías", "Jóvenes" ],
                 css_select("dialog[data-dialog-name='mas'] [data-more-items] > *").map { |item| item.text.squish }
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
    assert_select "dialog[data-dialog-name='qr'] [role='img'] > svg", false

    get participant_qr_path(participants(:maria))
    assert_response :success
    assert_select "#{frame} [role='img'] > svg", 1
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
      assert_select "[data-simple-kpi='Conteo']", text: /Sin pasar/
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
    assert_equal [ "Mi QR", "Escanear gafete", "Alertas", "Enfermería", "Conteo", "Historial" ],
                 css_select("dialog[data-dialog-name='mas'] [data-more-items] > *").map { |item| item.text.squish }
    assert_select "[data-simple-kpi='Jóvenes']"
    assert_select "[data-simple-kpi='Staff']"
  end

  test "Registro's committee gets Registro in the center, Inventario beside it and its QR inside Más" do
    registrar = participants(:maria).dup
    registrar.update!(rol: :logistica, first_name: "Rita", logistics_area: LogisticsArea.create!(name: "Registro", checkin: true))
    sign_in_as(User.create!(email_address: "rita@fsy.com", password: "Registro1!", participant: registrar))
    get dashboard_path

    assert_select "a[data-bottom-nav-item='Registro'][href='#{checkins_path}'] [data-tour='center']"
    assert_select "a[data-bottom-nav-item='Inventario'][href='#{inventories_path}']"
    assert_select "[data-bottom-nav-item='Mi QR']", false
    more = css_select("dialog[data-dialog-name='mas'] [data-more-items] > *").map { |item| item.text.squish }
    assert_equal [ "Mi QR", "Escanear gafete" ], more.first(2)
    assert_not_includes more, "Registro", "ya está en el centro"
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

  test "the joven gets their own bar: their company, their QR, the agenda and only their things in Más" do
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan)))

    get dashboard_path
    assert_select "nav[data-bottom-nav]" do
      assert_select "a[data-bottom-nav-item='Mi compañía'][href='#{my_company_path}']"
      assert_select "button[data-bottom-nav-item='Mi QR']"
    end
    # Los avisos los trae la campanita: «Más» no los repite, y al pie está Cerrar sesión.
    assert_equal [ "Mi perfil", "Novedades", "Configuración" ],
                 css_select("dialog[data-dialog-name='mas'] [data-more-items] > *").map { |item| item.text.squish }
    assert_select "dialog[data-dialog-name='mas'] form[action='#{session_path}'] button[data-more-sign-out]", text: /Cerrar sesión/
    # Su inicio: su compañía, no el último aviso, ni las cifras de un rol ni las gráficas del evento.
    assert_select "[data-joven-home] [data-joven-company][href='#{my_company_path}']", text: /Compañía 7/
    assert_select "[data-joven-latest-alert]", false
    assert_select "[data-simple-kpis]", false
    # Sin menú de cuenta: la foto lleva a su perfil, junto a la campanita.
    assert_select "button[aria-label='Menú de cuenta']", false
    assert_select "header a[data-profile-link][href='#{myprofile_participants_path}']"
    # En la computadora lo del menú de cuenta pasa al menú lateral, con Cerrar sesión al pie.
    assert_select "aside" do
      assert_select "a[href='#{myprofile_participants_path}']", text: /Mi perfil/
      assert_select "a[href='#{changelog_path}']", text: /Novedades/
      assert_select "a[href='#{settings_path}']", text: /Configuración/
      assert_select "button[data-aside-sign-out]", text: /Cerrar sesión/
    end

    get settings_path
    assert_select "#settings-simple"
    assert_select "#settings-companies", false
  end

  test "viewing as someone doesn't change their setting" do
    sign_in_as(users(:one))
    post view_as_path, params: { participant_id: participants(:maria).id }

    patch simple_mode_settings_path, params: { simple_mode: "0" }
    assert_redirected_to settings_path
    assert @counselor.reload.simple_mode?
  end
end
