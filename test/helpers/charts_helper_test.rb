require "test_helper"

class ChartsHelperTest < ActionView::TestCase
  test "age bars get darker as the count approaches the busiest age" do
    assert_equal [ "#c5d5e8", "#3671b2", "#1d447c" ], age_bar_colors([ 2, 5, 10 ])
  end

  test "age bar colors survive an all-zero series" do
    assert_equal [ "#c5d5e8", "#c5d5e8" ], age_bar_colors([ 0, 0 ])
  end

  test "roles have Spanish labels and a fallback color" do
    assert_equal "Logística", role_chart_label("logistica")
    assert_equal "#b4b8be", role_chart_color("desconocido")
  end

  test "summarizes multi-line labels as plain text" do
    assert_equal "Bello Horizonte: 3, Villa Flor: 1", chart_summary([ %w[Bello Horizonte], %w[Villa Flor] ], [ 3, 1 ])
  end
end
