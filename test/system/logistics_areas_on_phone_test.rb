require "application_system_test_case"

# Áreas de logística en un teléfono angosto: nada la estira de lado (las notas de las banderas, las pastillas,
# los nombres largos), ni con el toque ni en un teléfono que se declara con ratón.
class LogisticsAreasOnPhoneTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @admin.update!(simple_mode: true)
    { "Registro y bienvenida" => %i[checkin], "Finanzas y tesorería" => %i[finance food], "Enfermería" => %i[nursing], "Montaje" => [] }.each do |name, flags|
      area = LogisticsArea.create!(name: name, description: "Se encarga de #{name.downcase} durante toda la semana del evento.", **flags.index_with(true))
      3.times do |i|
        Participant.create!(first_name: "Persona#{i}", last_name: name.split.first, age: 30, stake: "puerto_cabezas", ward: "bilwi", shirt_number: "m",
                            gender: i.even? ? "H" : "M", rol: "logistica", logistics_area: area)
      end
    end
    Participant.create!(first_name: "Sin", last_name: "Área Asignada Todavía", age: 30, stake: "puerto_cabezas", ward: "bilwi", shirt_number: "m", gender: "H", rol: "logistica")
  end

  teardown do
    cdp("Emulation.clearDeviceMetricsOverride")
    cdp("Emulation.setTouchEmulationEnabled", enabled: false)
  end

  test "the areas page never scrolls sideways on a narrow phone" do
    sign_in_as(@admin)
    [ true, false ].product([ 320, 360, 390 ]).each do |touch, width|
      cdp("Emulation.setDeviceMetricsOverride", width: width, height: 800, deviceScaleFactor: 2, mobile: true)
      cdp("Emulation.setTouchEmulationEnabled", enabled: touch, maxTouchPoints: 1)
      visit logistics_areas_path
      assert_selector "[data-areas]"

      # El que se desliza es <main> (la barra inferior queda fija abajo), no el documento.
      assert_equal evaluate_script("document.querySelector('main').clientWidth"), evaluate_script("document.querySelector('main').scrollWidth"),
                   "a #{width} px #{touch ? "con toque" : "con ratón"} la página se desliza de lado"
    end
  end

  private
    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
