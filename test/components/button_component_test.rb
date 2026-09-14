# frozen_string_literal: true

require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  test "nav item linking to the current page is active" do
    with_request_url "/dashboard" do
      component = render_inline(ButtonComponent.new(text: "Inicio", url: "/dashboard", icon: "home.svg", secondary_icon: "home-s.svg", is_nav: true))

      link = component.css("a[href='/dashboard']").first
      assert link, "expected a link to /dashboard"
      assert_includes link["class"], "bg-primary-gradient-right"
    end
  end

  test "nav item for another page is not active" do
    with_request_url "/dashboard" do
      component = render_inline(ButtonComponent.new(text: "Staff", url: "/participants/staff", icon: "nav-people.svg", secondary_icon: "nav-people-s.svg", is_nav: true))

      refute_includes component.css("a").first["class"], "bg-primary-gradient-right"
    end
  end

  test "disabled nav item renders as inert text, not a link" do
    with_request_url "/dashboard" do
      component = render_inline(ButtonComponent.new(text: "Reportes", secondary_icon: "stake.svg", is_nav: true, disabled: true))

      assert_empty component.css("a")
      inert = component.css("[aria-disabled='true']").first
      assert inert, "expected an aria-disabled element"
      assert_includes inert["class"], "cursor-not-allowed"
      assert_includes component.text, "Reportes"
    end
  end

  test "disabled nav item is never active, even when its url matches the current page" do
    with_request_url "/dashboard" do
      component = render_inline(ButtonComponent.new(text: "Inicio", url: "/dashboard", is_nav: true, disabled: true))

      assert_empty component.css("a")
      refute_includes component.css("[aria-disabled='true']").first["class"], "bg-primary-gradient-right"
    end
  end
end
