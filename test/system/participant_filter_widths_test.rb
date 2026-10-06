require "application_system_test_case"

# Los filtros de Jóvenes y Staff tienen ancho fijo: un barrio de nombre largo ya no estira la fila hasta
# tener que deslizarla de lado en un escritorio mediano.
class ParticipantFilterWidthsTest < ApplicationSystemTestCase
  setup { sign_in_as users(:one) }

  [ 1100, 1280, 1440 ].each do |width|
    test "the filter row fits at #{width}px, even with a long ward chosen" do
      page.driver.browser.manage.window.resize_to(width, 900)
      visit participants_path(stake: "villa_flor", ward: "catorce_de_septiembre", care: "medical_information")
      save_screenshot(File.join(ENV["SCREENSHOTS"], "filtros-jovenes-#{width}.png")) if ENV["SCREENSHOTS"]
      assert_filter_row_fits

      visit staff_participants_path(ward: "catorce_de_septiembre", rol: "director_logistica")
      save_screenshot(File.join(ENV["SCREENSHOTS"], "filtros-staff-#{width}.png")) if ENV["SCREENSHOTS"]
      assert_filter_row_fits
    end
  end

  private
    def assert_filter_row_fits
      row = find("[data-participant-filters]")
      assert_equal row.evaluate_script("this.clientWidth"), row.evaluate_script("this.scrollWidth"), "the filters scroll sideways"
      assert_equal page.evaluate_script("document.documentElement.clientWidth"), page.evaluate_script("document.documentElement.scrollWidth")
    end
end
