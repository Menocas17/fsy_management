# frozen_string_literal: true

class StakeSpanComponent < ViewComponent::Base
  # name: lo que se lee; sin él, la estaca. Una estaca escrita a mano (staff de otra estaca) va en gris.
  def initialize(stake:, name: nil)
    @stake = stake
    @name = name || stake&.titleize
  end

  def stake_color
    ChartsHelper.chip(ChartsHelper::STAKE_CATEGORY[@stake])
  end
end
