require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  setup { ApplicationHelper::ICON_CACHE.clear }

  test "a cached icon is the same svg rails_icons draws" do
    drawn = RailsIcons::Helpers::IconHelper.instance_method(:icon).bind_call(self, "bell", class: "w-5 h-5")

    2.times { assert_equal drawn, icon("bell", class: "w-5 h-5") }
    assert_predicate icon("bell", class: "w-5 h-5"), :html_safe?
    assert_equal 1, ApplicationHelper::ICON_CACHE.size
  end

  test "different arguments are different icons" do
    refute_equal icon("bell", class: "w-4 h-4"), icon("bell", class: "w-5 h-5")
  end

  test "a missing icon still fails and is not cached" do
    2.times { assert_raises(Icons::IconNotFound) { icon("no-existe-este-icono") } }
    assert_empty ApplicationHelper::ICON_CACHE
  end
end
