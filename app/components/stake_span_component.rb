# frozen_string_literal: true

class StakeSpanComponent < ViewComponent::Base
  def initialize(stake:)
    @stake = stake
  end

  def stake_color
    case @stake
    when "bello_horizonte"
      "bg-cyan-100"

    when "las_americas"
      "bg-indigo-100"

    when "villa_flor"
      "bg-green-100"

    when "puerto_cabezas"
      "bg-amber-100"
    end
  end
end
