# frozen_string_literal: true

require "test_helper"

class TableComponentTest < ViewComponent::TestCase
  test "shows a readable gender and a dash when company and room are missing" do
    with_request_url "/participants" do
      component = render_inline(TableComponent.new(participants: [ participants(:juan) ]))

      assert_includes component.text, "Hombre"
      assert_includes component.text, "—"
      refute_includes component.text, "Comp."
    end
  end

  test "hides the edit action from non-admin viewers" do
    with_request_url "/participants" do
      component = render_inline(TableComponent.new(participants: [ participants(:juan) ]))

      assert_empty component.css("a[title='Editar']")
      assert component.css("a[title='Ver perfil']").present?
    end
  end
end
