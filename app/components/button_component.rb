# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(url:, text:, type:, icon: nil)
    @url = url
    @text = text
    @type = type
    @icon = icon
  end

  def styles
    if @type === "muted"
      "border py-1 px-2 border-gray-200 shadow-md rounded-lg pointer-cursor text-gray-600 text-sm"

    end
  end
end
