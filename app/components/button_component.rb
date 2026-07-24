# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(url: nil, text:, type:, icon: nil, is_submit: false)
    @url = url
    @text = text
    @type = type
    @icon = icon
    @is_submit = is_submit
  end

  def styles
    if @type === "muted"
        "border py-1 px-2 border-gray-200 shadow-md rounded-lg pointer-cursor text-gray-600 text-sm hover:border-gray-400 transition"
    elsif @type === "primary"
        "border py-2 px-4 shadow-md rounded-xl pointer-cursor text-white text-sm font-bold bg-[#095581] cursor-pointer hover:border-gray-600 transition"
    elsif @type === "cancel"
        "border border-gray-300 text-gray-600 py-2 px-4  shadow-md rounded-xl pointer-cursor text-sm font-bold  cursor-pointer hover:border-gray-600 transition"
    elsif @type === "delete"
        "border py-2 px-4  shadow-md rounded-xl pointer-cursor text-white text-sm font-bold bg-rose-800 cursor-pointer hover:border-gray-600 transition"

    end
  end
end
