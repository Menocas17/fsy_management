require "test_helper"

class ChangelogEntryTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def entry(id, roles: [])
    ChangelogEntry.new(id: id, date: "2026-10-0#{id.last}", title: "Cambio #{id}", summary: "Resumen #{id}", roles: roles)
  end

  test "the changelog file loads, newest first, with unique ids" do
    entries = ChangelogEntry.all
    assert entries.any?
    assert_equal entries.map(&:id).uniq, entries.map(&:id)
    assert_equal entries.map(&:date).sort.reverse, entries.map(&:date)
  end

  test "the first run announces only the newest entry, later runs only what is new, once" do
    old, newer = entry("e1"), entry("e2")

    assert_difference -> { Alert.source_novedades.count }, 1 do
      assert_equal [ "e2" ], ChangelogEntry.announce_pending!([ newer, old ]).map(&:id)
    end
    assert_no_difference -> { Alert.count } do
      ChangelogEntry.announce_pending!([ newer, old ])
    end

    assert_difference -> { Alert.source_novedades.count }, 2 do
      ChangelogEntry.announce_pending!([ entry("e4"), entry("e3"), newer, old ])
    end
    assert_equal [ "Novedades: Cambio e3", "Novedades: Cambio e4" ], Alert.source_novedades.order(:created_at, :id).last(2).map(&:title)
  end

  test "an entry for some roles becomes a role alert that links to its place in the page" do
    entry("e1", roles: [ "consejero" ]).announce!
    alert = Alert.source_novedades.last

    assert alert.audience_por_roles?
    assert_equal [ "consejero" ], alert.target_roles
    assert_equal "/novedades#novedad-e1", alert.link_path
  end

  test "news of the app also reach the phones" do
    assert_enqueued_jobs(1, only: PushNotificationJob) { entry("e1").announce! }
  end

  test "each person sees the entries for everybody and for their role" do
    entries = [ entry("e1"), entry("e2", roles: [ "director" ]) ]
    assert_equal [ "e1" ], ChangelogEntry.visible_to(participants(:maria), entries).map(&:id)
    assert_equal [ "e1", "e2" ], ChangelogEntry.visible_to(nil, entries).map(&:id)
  end
end
