# frozen_string_literal: true

class AvatarComponent < ViewComponent::Base
  def initialize (participant:, is_profile: false, size: nil)
    @participant = participant
    @is_profile = is_profile
    @size = size
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

  def css_classes
    if @is_profile
      "w-[72px] h-[72px] md:w-[92px] md:h-[92px] rounded-panel md:rounded-panel shrink-0 text-2xl md:text-[28px] border-4 border-surface"
    elsif @size == :sm
      "w-7 h-7 rounded-full shrink-0 text-[10px]"
    else
      "w-10 h-10 rounded-full shrink-0"
    end
  end

  # Iniciales en los tintes de la paleta del sistema, no un arcoíris de quince: el avatar es lo que más se
  # repite en las listas. Cada nombre cae siempre en el mismo tinte.
  AVATAR_TINTS = [
    "bg-primary-100 text-primary-800 dark:bg-primary-700/40 dark:text-primary-100",
    "bg-cat-blue/15 text-cat-blue-ink",
    "bg-cat-teal/15 text-cat-teal-ink",
    "bg-cat-green/15 text-cat-green-ink",
    "bg-cat-amber/20 text-cat-amber-ink"
  ].freeze
  AVATAR_FALLBACK = "bg-canvas text-ink-500 dark:bg-slate-700 dark:text-slate-300".freeze

  def avatar_colors_for(name)
    return AVATAR_FALLBACK if name.blank?

    AVATAR_TINTS[name.sum % AVATAR_TINTS.size]
  end
end
