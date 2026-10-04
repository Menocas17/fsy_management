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
  # banner: la página abre con un banner (Inicio, los perfiles): en el teléfono se acerca a la barra superior.
  def initialize(width: :page, data: {}, banner: false)
    @width = WIDTHS.fetch(width)
    @data = data
    @banner = banner
  end

  def top_padding
    @banner ? "pt-3 md:pt-8" : "pt-6 md:pt-8"
  end
end
