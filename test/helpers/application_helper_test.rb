require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  setup { ApplicationHelper::ICON_CACHE.clear }

  test "a cached icon is the same svg rails_icons draws" do
    drawn = RailsIcons::Helpers::IconHelper.instance_method(:icon).bind_call(self, "bell", class: "w-5 h-5")

    2.times { assert_equal drawn, icon("bell", class: "w-5 h-5") }
    assert_predicate icon("bell", class: "w-5 h-5"), :html_safe?
    assert_equal 1, ApplicationHelper::ICON_CACHE.size
  end

  test "different arguments are different icons" do
    refute_equal icon("bell", class: "w-4 h-4"), icon("bell", class: "w-5 h-5")
  end

  test "a missing icon still fails and is not cached" do
    2.times { assert_raises(Icons::IconNotFound) { icon("no-existe-este-icono") } }
    assert_empty ApplicationHelper::ICON_CACHE
  end

  test "storage_url points at the public bucket when there is one" do
    blob = ActiveStorage::Blob.new(key: "abc123")

    with_public_storage("https://fotos.example.com") { assert_equal "https://fotos.example.com/abc123", storage_url(blob) }
    with_public_storage(nil) { assert_same blob, storage_url(blob) }
  end

  test "an unprocessed variant keeps the active storage route, which processes it" do
    variant = Struct.new(:key).new(nil)

    with_public_storage("https://fotos.example.com") { assert_same variant, storage_url(variant) }
  end

  private
    def with_public_storage(url)
      previous = Rails.configuration.x.public_storage_url
      Rails.configuration.x.public_storage_url = url
      yield
    ensure
      Rails.configuration.x.public_storage_url = previous
    end
end
