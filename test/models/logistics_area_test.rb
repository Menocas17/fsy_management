require "test_helper"

class LogisticsAreaTest < ActiveSupport::TestCase
  test "names are required and unique" do
    LogisticsArea.create!(name: "Finanzas")

    assert_not LogisticsArea.new(name: "Finanzas").valid?
    assert_not LogisticsArea.new(name: "").valid?
  end

  test "deleting an area keeps its members without an area" do
    area = LogisticsArea.create!(name: "Tecnología")
    member = participants(:maria)
    member.update!(rol: "logistica", logistics_area: area)

    area.destroy

    assert_nil member.reload.logistics_area
  end
end
