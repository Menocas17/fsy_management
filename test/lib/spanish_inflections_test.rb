require "test_helper"

# pluralize sigue al idioma de la app: sin reglas del español dejaba «4 inventario · 17 artículo».
class SpanishInflectionsTest < ActionView::TestCase
  test "counts in the views are pluralized in Spanish" do
    I18n.with_locale(:es) do
      assert_equal "4 inventarios", pluralize(4, "inventario")
      assert_equal "3 áreas", pluralize(3, "área")
      assert_equal "2 actividades", pluralize(2, "actividad")
      assert_equal "2 jóvenes", pluralize(2, "joven")
      assert_equal "1 artículo", pluralize(1, "artículo")
    end
  end
end
