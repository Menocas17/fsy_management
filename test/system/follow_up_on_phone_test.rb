require "application_system_test_case"

# Enfermería y el seguimiento de asignaciones en un teléfono angosto: nada se sale de lado. «Pasaron por
# enfermería» tenía unas pestañas junto al título que en 320 px corrían la página; ahora es un interruptor.
class FollowUpOnPhoneTest < ApplicationSystemTestCase
  teardown do
    cdp("Emulation.clearDeviceMetricsOverride")
  end

  test "the infirmary board and the assignments follow-up never scroll sideways" do
    joven = participants(:juan)
    joven.assignments.create!(title: "Dirigir la oración de la mañana en el auditorio", assigned_by_name: "Administrador del sistema")
    sign_in_as(users(:one))

    [ 320, 360, 390 ].each do |width|
      cdp("Emulation.setDeviceMetricsOverride", width: width, height: 800, deviceScaleFactor: 2, mobile: true)
      { infirmary_visits_path => "[data-infirmary-section=pasaron] [role=switch]",
        assignments_path => "[data-assignment-row]" }.each do |path, selector|
        visit path
        assert_selector selector
        assert_equal evaluate_script("document.querySelector('main').clientWidth"), evaluate_script("document.querySelector('main').scrollWidth"),
                     "#{path} a #{width} px se desliza de lado"
      end
    end

    visit infirmary_visits_path
    find("[data-infirmary-section=pasaron] [role=switch]").click
    assert_selector "[data-infirmary-section=pasaron] [role=switch][aria-checked=false]"
  end

  private
    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
