# frozen_string_literal: true

require "test_helper"

# El esqueleto de lo que carga aparte: dice «Cargando…» a los lectores de pantalla y dibuja la forma de lo que viene.
class SkeletonComponentTest < ViewComponent::TestCase
  test "each variant announces itself once and hides its shapes from screen readers" do
    SkeletonComponent::VARIANTS.each do |variant|
      page = render_inline(SkeletonComponent.new(variant: variant, label: "Cargando la actividad…"))

      status = page.css("[role=status][data-skeleton='#{variant}']").first
      assert status, "#{variant} renders a status"
      assert_equal "Cargando la actividad…", status.css(".sr-only").text
      assert status.css("[aria-hidden=true] .skeleton").any?, "#{variant} draws its shapes"
    end
  end

  test "rows and details draw as many rows as asked" do
    assert_equal 4, render_inline(SkeletonComponent.new(variant: :rows, count: 4)).css(".size-9.skeleton").size
    assert_equal 2, render_inline(SkeletonComponent.new(variant: :details, count: 2)).css(".rounded-control.skeleton").size
  end

  test "an unknown variant fails loudly" do
    assert_raises(ArgumentError) { SkeletonComponent.new(variant: :table) }
  end
end
