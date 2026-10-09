require "test_helper"

# Las listas de la agenda van en caché (agenda/show): con la caché encendida, como en producción, una
# actividad nueva, editada o borrada se ve en la visita siguiente.
class AgendaCacheTest < ActionDispatch::IntegrationTest
  setup do
    @cache, @perform = Rails.cache, ActionController::Base.perform_caching
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    ActionController::Base.perform_caching = true
    sign_in_as(users(:one))
    @day = Activity.event_days.first
    @activity = Activity.create!(title: "Devocional", category: :clase, date: @day.to_s, start_time: "09:00", end_time: "10:00")
  end

  teardown do
    Rails.cache = @cache
    ActionController::Base.perform_caching = @perform
  end

  test "a new, edited or deleted activity shows on the next visit" do
    get agenda_path(date: @day)
    assert_select "[data-activity-id='#{@activity.id}']", text: /Devocional/

    travel 1.second
    @activity.update!(title: "Devocional matutino")
    get agenda_path(date: @day)
    assert_select "[data-activity-id='#{@activity.id}']", text: /Devocional matutino/

    other = Activity.create!(title: "Taller", category: :clase, date: @day.to_s, start_time: "11:00", end_time: "12:00")
    get agenda_path(date: @day)
    assert_select "[data-activity-id='#{other.id}']"

    @activity.destroy!
    get agenda_path(date: @day)
    assert_select "[data-activity-id='#{@activity.id}']", false
  end
end
