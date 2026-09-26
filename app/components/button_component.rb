# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(url: nil, text:, type: nil, icon: nil, secondary_icon: nil, is_submit: false, is_delete: nil, is_button: nil, is_nav: nil, classes: nil, section: nil, method: nil, disabled: false, lucide_icon: nil, active_paths: [], except_paths: [])
    @url = url
    @disabled = disabled
    @lucide_icon = lucide_icon
    @active_paths = active_paths
    @except_paths = except_paths
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
      "border py-1 px-2 border-gray-200 text-gray-600 rounded-lg hover:border-gray-400 font-normal dark:border-slate-600 dark:text-slate-300 dark:hover:border-slate-400"
    when "primary"
      "border py-2 px-4 text-white bg-primary-600 hover:border-gray-600"

    when "cancel"
      "border border-gray-300 text-gray-600 hover:border-gray-600 py-1 px-2 dark:border-slate-600 dark:text-slate-300 dark:hover:border-slate-400"
    when "delete"
      "border py-2 px-4 text-white bg-rose-800 hover:border-gray-600"
    else
      "flex items-center gap-3 px-4 py-2.5 rounded-xl text-[14.5px] font-semibold transition-colors duration-200"
    end

    [ base_styles, type_styles, @classes ].compact.join(" ")
  end

  def disabled?
    @disabled
  end

  # A nav item stays highlighted on its nested pages (new, edit, show) through active_paths;
  # except_paths keeps a sibling from lighting up too (Jóvenes vs Staff, both under /participants).
  def active?
    return false if disabled? || @url.nil?
    # A ?from= param says which list the person came from, and that wins over path matching.
    return @section.present? && params[:from] == @section if params[:from].present?
    return true if current_page?(@url)
    return false if @except_paths.any? { |path| request.path.start_with?(path) }

    @active_paths.any? { |path| request.path.start_with?(path) }
  end

  def active_classes
    active? ? "bg-primary-gradient-right text-white shadow-sm" : "text-ink-500 hover:bg-primary-50 hover:text-primary-700 dark:text-slate-400 dark:hover:bg-slate-700/60 dark:hover:text-slate-100"
  end

  def current_icon
    active? ? @icon : @secondary_icon
  end
end
