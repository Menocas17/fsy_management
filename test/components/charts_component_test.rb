# frozen_string_literal: true

require "test_helper"

# Las gráficas del inicio, dibujadas en el servidor: cada barra y cada parte de la dona con su color y su
# proporción, y la descripción completa para los lectores de pantalla.
class ChartsComponentTest < ViewComponent::TestCase
  test "each column shows its value, its label lines and a height relative to the tallest" do
    page = render_inline(ColumnChartComponent.new(labels: [ %w[Bello Horizonte], "Villa Flor" ], values: [ 50, 100 ],
                                                  colors: %w[#0077b6 #2a9d8f], label: "Jóvenes por estaca. Bello Horizonte: 50, Villa Flor: 100"))

    chart = page.css("[data-column-chart][role=img]").first
    assert_equal "Jóvenes por estaca. Bello Horizonte: 50, Villa Flor: 100", chart["aria-label"]
    assert_equal %w[50 100], page.css("[data-chart-value]").map(&:text)
    bars = page.css("span[style*='background']")
    assert_includes bars[0]["style"], "* 0.5)"
    assert_includes bars[1]["style"], "* 1.0)"
    assert_includes bars[0]["style"], "#0077b6"
    assert_equal "BelloHorizonte", page.css("p").first.text.gsub(/\s/, "")
  end

  test "columns with no data draw empty bars instead of dividing by zero" do
    page = render_inline(ColumnChartComponent.new(labels: %w[A B], values: [ 0, 0 ], colors: %w[#111111 #222222], label: "Vacía"))

    assert_equal %w[0 0], page.css("[data-chart-value]").map(&:text)
    assert page.css("span[style*='background']").all? { |bar| bar["style"].include?("* 0.0)") }
  end

  test "the donut draws one arc per non-empty part, in proportion, with the total in the middle" do
    page = render_inline(DonutChartComponent.new(values: [ 1, 0, 3 ], colors: %w[#aa0000 #00aa00 #0000aa], total: 4, label: "Por rol"))

    arcs = page.css("circle")
    assert_equal %w[#aa0000 #0000aa], arcs.map { |arc| arc["stroke"] }
    circumference = 2 * Math::PI * DonutChartComponent.new(values: [], colors: [], label: "").send(:radius)
    first, second = arcs.map { |arc| arc["stroke-dasharray"].split.first.to_f + DonutChartComponent::GAP }
    assert_in_delta circumference / 4, first, 0.05
    assert_in_delta circumference * 3 / 4, second, 0.05
    assert_equal "4", page.css("[data-chart-total]").text
    assert_equal "Por rol", page.css("[role=img]").first["aria-label"]
  end
end
