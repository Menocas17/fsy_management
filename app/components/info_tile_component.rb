# frozen_string_literal: true

class InfoTileComponent < ViewComponent::Base
  def initialize(title:, icon:, data:)
    @title = title
    @icon = icon
    @data = data
  end

  def value
      Array(@data).compact_blank.presence || [ "N/A" ]
  end
  def text_alignment(title)
    title.to_s.length > 5 ? "pl-0" : "pl-8"
  end
end
