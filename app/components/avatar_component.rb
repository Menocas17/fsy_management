# frozen_string_literal: true

class AvatarComponent < ViewComponent::Base
  def initialize (participant:, css_class: "w-10 h-10 rounded-full shrink-0")
    @participant = participant
    @css_class = css_class
  end

  private

  def has_avatar?
    @participant.avatar.attached?
  end

  def avatar_url
    @participant.avatar.variant(:thumb)
  end

  def initials
    "#{@participant.first_name&.chr}#{@participant.last_name&.chr}".upcase
  end

  def avatar_colors_for(name)
      colors = [
      "bg-red-100 text-red-600",
      "bg-orange-100 text-orange-600",
      "bg-amber-100 text-amber-600",
      "bg-green-100 text-green-600",
      "bg-emerald-100 text-emerald-600",
      "bg-teal-100 text-teal-600",
      "bg-cyan-100 text-cyan-600",
      "bg-blue-100 text-blue-600",
      "bg-indigo-100 text-indigo-600",
      "bg-violet-100 text-violet-600",
      "bg-purple-100 text-purple-600",
      "bg-fuchsia-100 text-fuchsia-600",
      "bg-pink-100 text-pink-600",
      "bg-rose-100 text-rose-600",
      "bg-slate-100 text-slate-600"
    ]

    return colors.last if name.blank?

    index = name.sum % (colors.length - 1)
    colors[index]
  end
end
