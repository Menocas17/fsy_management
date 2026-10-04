# frozen_string_literal: true

require "test_helper"

# Las piezas comunes de la guía de estilo (DESIGN.md): que cada una use los tokens y el color que le tocan.
class DesignPiecesTest < ViewComponent::TestCase
  test "an icon tile is tinted by default and solid only when asked" do
    tint = render_inline(IconTileComponent.new(icon: "users", tone: :green)).css("[data-icon-tile]").first
    assert_includes tint["class"], "bg-cat-green/15"
    assert_includes tint["class"], "text-cat-green-ink"
    assert_includes tint["class"], "rounded-tile"

    solid = render_inline(IconTileComponent.new(icon: "users", tone: :amber, variant: :solid, size: :lg)).css("[data-icon-tile]").first
    assert_includes solid["class"], "bg-cat-amber-solid"
    assert_includes solid["class"], "size-[52px]"
  end

  test "an unknown tone fails loudly instead of rendering an unstyled tile" do
    assert_raises(KeyError) { render_inline(IconTileComponent.new(icon: "users", tone: :purple)) }
  end

  test "a large stat tile shows the figure with a solid tile and links when given an href" do
    tile = render_inline(StatTileComponent.new(value: 445, label: "Jóvenes", icon: "user-round", tone: :green, href: "/participants"))

    link = tile.css("a[data-stat-tile][href='/participants']").first
    assert link
    assert_equal "445", link.css("[data-stat-value]").text.strip
    assert link.css("[data-icon-tile]").first["class"].include?("bg-cat-green-solid")
  end

  test "a small stat tile is a tinted support figure, not a card" do
    tile = render_inline(StatTileComponent.new(value: 100, label: "con alergias", icon: "heart-pulse", tone: :rose, size: :sm))

    assert_selector "div[data-stat-tile].bg-sunken:not([href])"
    assert tile.css("[data-icon-tile]").first["class"].include?("bg-cat-rose/15")
  end

  test "a small stat tile that links looks like a button; one that doesn't stays a flat figure" do
    render_inline(StatTileComponent.new(value: 100, label: "con alergias", icon: "heart-pulse", tone: :rose, size: :sm, href: "/participants?care=allergies"))
    assert_selector "a[data-stat-tile].bg-surface.border svg", count: 2 # su ícono y la flecha

    render_inline(StatTileComponent.new(value: 220, label: "Salón Nicaragua", icon: "hand-platter", tone: :amber, size: :sm))
    assert_selector "div[data-stat-tile].bg-sunken"
    assert_no_selector "[data-stat-tile].border"
  end

  test "a chip is a pill in its tone" do
    chip = render_inline(ChipComponent.new(label: "Solo lectura")).css("[data-chip]").first
    assert_equal "Solo lectura", chip.text.strip
    assert_includes chip["class"], "rounded-full"
    assert_includes chip["class"], "text-label"
  end

  test "the empty state names itself and shows its action only when there is one" do
    render_inline(EmptyStateComponent.new(title: "Sin asignaciones todavía", text: "Agrega una.", name: "asignaciones"))
    assert_selector "[data-empty-state='asignaciones']", text: /Sin asignaciones todavía/
    assert_no_selector "[data-empty-state] .mt-2"

    render_inline(EmptyStateComponent.new(title: "Nada")) { |empty| empty.with_action { "Crear" } }
    assert_selector "[data-empty-state] .mt-2", text: "Crear"
  end

  test "the segmented toggle marks the current view" do
    render_inline(SegmentedToggleComponent.new(label: "Vista", items: [
      { text: "Semana", href: "/agenda", active: true }, { text: "Día", href: "/agenda?view=dia" }
    ]))

    assert_selector "nav[aria-label='Vista'] a[aria-current='page']", text: "Semana"
    assert_selector "nav a:not([aria-current])", text: "Día"
  end

  test "the segmented toggle mixes options of the same page in place instead of visiting a new one" do
    with_request_url "/agenda?view=semana" do
      render_inline(SegmentedToggleComponent.new(label: "Vista", items: [
        { text: "Día", href: "/agenda?view=dia" }, { text: "Capacitaciones", href: "/agenda/capacitaciones" }
      ]))
    end

    assert_selector "a[data-turbo-action='replace']", text: "Día"
    assert_selector "a:not([data-turbo-action])", text: "Capacitaciones"
  end

  test "the page frame picks one of the two widths and lays out its header" do
    render_inline(PageComponent.new(width: :form)) do |page|
      page.with_intro { "8 áreas" }
      page.with_actions { "Nueva área" }
      "Contenido"
    end

    assert_selector "[data-page='form'].max-w-form [data-page-header]", text: /8 áreas.*Nueva área/m
    assert_text "Contenido"
    assert_raises(KeyError) { PageComponent.new(width: :wide) }
  end
end
