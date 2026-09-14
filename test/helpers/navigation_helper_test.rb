require "test_helper"

class NavigationHelperTest < ActionView::TestCase
  test "lists the primary sections in sidebar order" do
    assert_equal [ "Inicio", "Jóvenes", "Staff", "Compañías", "Mi perfil" ], nav_items.map { |item| item[:text] }
  end

  test "every item renders as a nav button with a real route" do
    nav_items.each do |item|
      assert item[:is_nav], "#{item[:text]} should be a nav item"
      assert item[:url].start_with?("/"), "#{item[:text]} should point at an app route"
    end
  end

  test "items can be splatted straight into ButtonComponent" do
    nav_items.each { |item| assert ButtonComponent.new(**item) }
  end
end
