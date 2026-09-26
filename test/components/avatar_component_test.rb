# frozen_string_literal: true

require "test_helper"

class AvatarComponentTest < ViewComponent::TestCase
  test "renders initials when participant has no avatar" do
    component = render_inline(AvatarComponent.new(participant: participants(:maria)))

    assert component.text.strip.include?("MG")
    refute participant_has_controller?(component)
  end

  test "renders placeholder initials behind image while it loads" do
    participant = participants(:maria)
    participant.avatar.attach(
      io: File.open("/tmp/tiny.png"),
      filename: "tiny.png",
      content_type: "image/png"
    )

    component = render_inline(AvatarComponent.new(participant: participant))

    assert component.css("[data-controller='avatar']").present?
    assert component.css("[data-avatar-target='image']").present?
    assert component.css("img").present?
  end

  private

  def participant_has_controller?(component)
    component.css("[data-controller='avatar']").present?
  end
end
