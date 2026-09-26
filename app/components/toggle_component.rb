# frozen_string_literal: true

class ToggleComponent < ViewComponent::Base
  def initialize(id:, label:, action:, target:, description: nil)
    @id = id
    @label = label
    @description = description
    @action = action
    @target = target
  end

  def input_data
    { action: "change->preferences##{@action}", preferences_target: @target }
  end
end
