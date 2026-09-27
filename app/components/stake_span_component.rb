# frozen_string_literal: true

class StakeSpanComponent < ViewComponent::Base
  def initialize(stake:)
    @stake = stake
  end

  def stake_color
    ChartsHelper.chip(ChartsHelper::STAKE_CATEGORY[@stake])
  end
end
