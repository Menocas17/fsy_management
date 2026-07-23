# frozen_string_literal: true

class InfoTileComponent < ViewComponent::Base
  def initialize(title:, icon:, data:)
    @title = title
    @icon = icon
    @data = data
  end
end
