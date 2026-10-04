# frozen_string_literal: true

# El marco de toda página (DESIGN.md, «Layout»): el relleno, uno de los dos anchos y el encabezado de la página
# (una frase o un conteo a la izquierda, las acciones a la derecha). Ninguna vista pone su propio max-w-*.
#
#   <%= render PageComponent.new(width: :page) do |page| %>
#     <% page.with_intro { "8 áreas · 19 miembros" } %>
#     <% page.with_actions { link_to "Nueva área", ..., class: button_classes } %>
#     …contenido…
#   <% end %>
class PageComponent < ViewComponent::Base
  WIDTHS = { page: "max-w-page", form: "max-w-form" }.freeze

  renders_one :intro
  renders_one :actions

  # data: va en el contenedor de la página, por ejemplo el controlador de Stimulus que la gobierna.
  def initialize(width: :page, data: {})
    @width = WIDTHS.fetch(width)
    @data = data
  end
end
