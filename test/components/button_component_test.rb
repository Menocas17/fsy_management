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

  test "nav item stays active on nested pages listed in active_paths" do
    with_request_url "/companies/123" do
      component = render_inline(ButtonComponent.new(text: "Compañías", url: "/companies", lucide_icon: "building-2", is_nav: true, active_paths: [ "/companies" ]))

      link = component.css("a[href='/companies']").first
      assert_equal "page", link["aria-current"]
      assert_includes link["class"], "bg-primary-gradient-right"
    end
  end

  test "a sibling under the same prefix doesn't light up" do
    with_request_url "/participants/staff" do
      component = render_inline(ButtonComponent.new(text: "Jóvenes", url: "/participants", lucide_icon: "users", is_nav: true,
                                                    active_paths: [ "/participants" ], except_paths: [ "/participants/staff" ]))

      assert_nil component.css("a").first["aria-current"]
    end
  end

  test "coming from a list keeps that list highlighted, not the one matching the path" do
    with_request_url "/participants/42/edit?from=staff" do
      jovenes = render_inline(ButtonComponent.new(text: "Jóvenes", url: "/participants", lucide_icon: "users", is_nav: true,
                                                  section: "jovenes", active_paths: [ "/participants" ]))
      assert_nil jovenes.css("a").first["aria-current"]

      staff = render_inline(ButtonComponent.new(text: "Staff", url: "/participants/staff", lucide_icon: "user-check", is_nav: true,
                                                section: "staff", active_paths: [ "/participants/staff" ]))
      assert_equal "page", staff.css("a").first["aria-current"]
    end
  end

  test "nav item can use a Lucide icon instead of an image asset" do
    with_request_url "/dashboard" do
      component = render_inline(ButtonComponent.new(text: "Organigrama", url: "/organigrama", lucide_icon: "network", is_nav: true))

      assert component.css("a[href='/organigrama'] svg").present?
      assert_empty component.css("img")
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
