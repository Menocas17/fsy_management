require "test_helper"

class CareNoteCleanupTest < ActiveSupport::TestCase
  test "shows what it would clear and what short phrases stay, and clears only when run" do
    juan = participants(:juan)
    juan.update!(medical_information: "Todo bien", diet: "Vegetariano", emotional_information: "Normal")

    cleanup = CareNoteCleanup.new
    assert_equal [ [ "Todo bien", 1 ] ], cleanup.cleared_in("medical_information")
    assert_equal [ [ "Vegetariano", 1 ] ], cleanup.short_kept("diet")
    assert_equal "Vegetariano", juan.reload.diet, "nothing changes before running it"

    assert_difference -> { AuditLog.count }, 1 do
      assert_equal 1, cleanup.run
    end
    juan.reload
    assert_equal [ nil, "Vegetariano", nil ], [ juan.medical_information, juan.diet, juan.emotional_information ]
    assert_empty CareNoteCleanup.new.changes
  end
end
