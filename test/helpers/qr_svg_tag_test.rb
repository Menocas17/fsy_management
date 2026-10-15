require "test_helper"

# El QR de una ficha lleva el nombre de la persona como etiqueta. rqrcode escribe sus atributos sin escapar: un
# apellido con comillas metía atributos (y con ellos código) en el <svg>. La etiqueta va en el div, escapada.
class QrSvgTagTest < ActionView::TestCase
  include UiHelper

  test "a name with quotes and markup stays text, never attributes" do
    html = qr_svg_tag("https://fsy.example/p/1", label: %(Código QR de x" onload="alert(1)) + "<b>")
    fragment = Nokogiri::HTML5.fragment(html)
    wrapper = fragment.at_css("div")

    assert_equal %(Código QR de x" onload="alert(1)<b>), wrapper["aria-label"]
    assert_equal "img", wrapper["role"]
    assert_nil fragment.at_css("svg")["onload"]
    assert_empty fragment.css("[onload], b")
    assert_equal "true", fragment.at_css("svg")["aria-hidden"]
  end
end
