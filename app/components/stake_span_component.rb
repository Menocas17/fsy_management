# frozen_string_literal: true

class StakeSpanComponent < ViewComponent::Base
  COLORS = {
    "bello_horizonte" => "bg-cat-blue/15 text-cat-blue",
    "las_americas" => "bg-cat-indigo/15 text-cat-indigo",
    "villa_flor" => "bg-cat-green/15 text-cat-green",
    "puerto_cabezas" => "bg-cat-amber/20 text-amber-700 dark:text-cat-amber"
  }.freeze

  def initialize(stake:)
    @stake = stake
  end

  def stake_color
    COLORS.fetch(@stake, "bg-canvas text-ink-500 dark:bg-slate-700 dark:text-slate-300")
  end
end
