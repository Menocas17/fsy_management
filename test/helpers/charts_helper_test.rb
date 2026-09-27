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
    assert_equal ChartsHelper.hex("neutral"), role_chart_color("desconocido")
  end

  test "a role or a stake has the same color in its chip and in the charts" do
    assert_equal ChartsHelper.hex(ChartsHelper::ROLE_CATEGORY["consejero"]), role_chart_color("consejero")
    assert_includes RoleSpanComponent.new(role: "consejero").styles, "cat-#{ChartsHelper::ROLE_CATEGORY["consejero"]}"

    assert_equal stake_chart_color("villa_flor"), stake_chart_color("Villa Flor")
    assert_includes StakeSpanComponent.new(stake: "villa_flor").stake_color, "cat-#{ChartsHelper::STAKE_CATEGORY["villa_flor"]}"
  end

  test "no two staff roles share a color in the roles chart" do
    staff = ChartsHelper::ROLE_CATEGORY.except("joven").values
    assert_equal staff.uniq.size, staff.size
  end

  test "summarizes multi-line labels as plain text" do
    assert_equal "Bello Horizonte: 3, Villa Flor: 1", chart_summary([ %w[Bello Horizonte], %w[Villa Flor] ], [ 3, 1 ])
  end
end
