require "application_system_test_case"

# Los selectores que se salían de la pantalla del teléfono: las pestañas de la carga masiva y las noches de la
# asistencia nocturna (ahora flechas, como la agenda).
class DayPickersOnPhoneTest < ApplicationSystemTestCase
  setup do
    resize_to_mobile
    sign_in_as users(:one)
  end

  test "the bulk upload tabs scroll sideways inside their rail instead of widening the page" do
    visit new_participant_import_path(tipo: "consejeros")
    save_screenshot(File.join(ENV["SCREENSHOTS"], "carga-celular.png")) if ENV["SCREENSHOTS"]

    assert_selector "[data-import-tab=jovenes]", visible: :all
    assert_no_page_scroll_sideways
  end

  test "the night attendance panel walks the nights with arrows and says when a night is closed" do
    company = Company.create!(number: 1)
    participants(:juan).update!(company: company)
    visit night_attendances_path(noche: Rails.configuration.x.event_start_on.iso8601)
    save_screenshot(File.join(ENV["SCREENSHOTS"], "asistencia-panel-celular.png")) if ENV["SCREENSHOTS"]

    assert_selector "[data-night-window=por_venir]"
    find("[data-day-pager=next]").click
    assert_selector "[data-night-pager='#{(Rails.configuration.x.event_start_on + 1).iso8601}']"
    assert_no_page_scroll_sideways
  end

  private
    def assert_no_page_scroll_sideways
      assert_equal page.evaluate_script("document.documentElement.clientWidth"), page.evaluate_script("document.documentElement.scrollWidth")
    end
end
