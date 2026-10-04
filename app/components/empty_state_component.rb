# frozen_string_literal: true

# El único estado vacío de la aplicación: qué falta y, si la persona puede, qué hacer (el slot action).
# name queda en data-empty-state para las pruebas y para quien quiera apuntarle.
class EmptyStateComponent < ViewComponent::Base
  renders_one :action

  def initialize(title:, text: nil, icon: "inbox", tone: :primary, name: nil)
    @title = title
    @text = text
    @icon = icon
    @tone = tone
    @name = name
  end
end
