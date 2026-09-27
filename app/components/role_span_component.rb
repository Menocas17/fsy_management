class RoleSpanComponent < ViewComponent::Base
  def initialize(role:)
    @role = role
  end

  def label
    Participant.role_label(@role) if @role.present?
  end

  def styles
    ChartsHelper.chip(ChartsHelper::ROLE_CATEGORY[@role])
  end
end
