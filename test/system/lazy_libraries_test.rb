require "application_system_test_case"

# ApexCharts y jsQR no se precargan en cada página: sus controladores los piden al conectarse.
class LazyLibrariesTest < ApplicationSystemTestCase
  setup { sign_in_as users(:one) }

  test "the dashboard charts still draw once apexcharts arrives" do
    assert_selector "[data-controller~='chart'] .apexcharts-canvas", minimum: 1
  end

  test "pages without charts or cameras do not download those libraries" do
    visit scan_path

    assert_no_selector "link[rel=modulepreload][href*='apexcharts']", visible: :all
    assert_no_selector "link[rel=modulepreload][href*='jsqr']", visible: :all
    # El lector de la página sí pide jsQR al conectarse.
    assert_equal "function", evaluate_async_script(<<~JS)
      const done = arguments[0]
      import("jsqr").then((module) => done(typeof module.default))
    JS
  end
end
