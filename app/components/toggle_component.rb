# frozen_string_literal: true

class ToggleComponent < ViewComponent::Base
  # Casi todos los interruptores son de preferencias; el de notificaciones cuelga de su propio controlador.
  def initialize(id:, label:, action:, target:, description: nil, controller: "preferences")
    @id = id
    @label = label
    @description = description
    @action = action
    @target = target
    @controller = controller
  end

  def input_data
    { action: "change->#{@controller}##{@action}" }.merge("#{@controller}_target": @target)
  end
end
