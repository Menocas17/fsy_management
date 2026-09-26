require "test_helper"

class ChartsHelperTest < ActionView::TestCase
  # Contra la escala, no contra los hex: cambiar de paleta no debería romper estas pruebas.
  test "age bars get darker as the count approaches the busiest age" do
    lightest = ChartsHelper::AGE_LIGHTEST
    half = ChartsHelper::AGE_SHADES[2].last
    darkest = ChartsHelper::AGE_SHADES[0].last

    assert_equal [ lightest, half, darkest ], age_bar_colors([ 2, 5, 10 ])
  end

  test "age bar colors survive an all-zero series" do
    assert_equal [ ChartsHelper::AGE_LIGHTEST ] * 2, age_bar_colors([ 0, 0 ])
  end

  test "roles have Spanish labels and a fallback color" do
    assert_equal "Logística", role_chart_label("logistica")
    assert_equal "#b4b8be", role_chart_color("desconocido")
  end

  test "summarizes multi-line labels as plain text" do
    assert_equal "Bello Horizonte: 3, Villa Flor: 1", chart_summary([ %w[Bello Horizonte], %w[Villa Flor] ], [ 3, 1 ])
  end
end
