# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(url: nil, text:, type: nil, icon: nil, secondary_icon: nil, is_submit: false, is_delete: nil, is_button: nil, is_nav: nil, classes: nil, section: nil, method: nil)
    @url = url
    @text = text
    @type = type
    @icon = icon
    @is_submit = is_submit
    @classes = classes
    @is_delete = is_delete
    @is_button = is_button
    @secondary_icon = secondary_icon
    @is_nav = is_nav
    @section = section
    @method = method
  end

  def styles
    base_styles = case @type
    when "muted", "primary", "cancel", "delete"
      "transition cursor-pointer shadow-md rounded-xl text-sm font-bold flex items-center justify-center"
    else
      ""
    end

    type_styles = case @type
    when "muted"
      "border py-1 px-2 border-gray-200 text-gray-600 rounded-lg hover:border-gray-400 font-normal"
    when "primary"
      "border py-2 px-4 text-white bg-[#095581] hover:border-gray-600"

    when "cancel"
      "border border-gray-300 text-gray-600 hover:border-gray-600 py-1 px-2 "
    when "delete"
      "border py-2 px-4 text-white bg-rose-800 hover:border-gray-600"
    else
      "block py-3 pl-6 rounded-r-3xl mr-4 text-xl font"
    end

    [ base_styles, type_styles, @classes ].compact.join(" ")
  end

  def active?
    return false if @url.nil?
    return true if current_page?(@url)
    true if @section.present? && params[:from] == @section
  end

  def active_classes
    active? ? "bg-primary-gradient-right shadow-inner text-white" : " hover:bg-blue-100 transition-all duration-300"
  end

  def current_icon
    active? ? @icon : @secondary_icon
  end
end
