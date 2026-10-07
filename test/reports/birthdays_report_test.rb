require "test_helper"

class BirthdaysReportTest < ActiveSupport::TestCase
  def report
    BirthdaysReport.new(start_on: Date.new(2027, 1, 11), end_on: Date.new(2027, 1, 16))
  end

  test "lists January's birthdays by day and, apart, the ones during the FSY week, with the age they turn" do
    participants(:juan).update!(birth_date: Date.new(2010, 1, 14))
    participants(:maria).update!(birth_date: Date.new(2001, 1, 3))
    Participant.create!(first_name: "Ana", last_name: "Febrero", birth_date: Date.new(2011, 2, 14), stake: "villa_flor",
                        shirt_number: "m", gender: "M")

    month = report.send(:month_people).map { |person, _| person.first_name }
    week = report.send(:week_people)

    assert_equal %w[María Juan], month
    assert_equal [ participants(:juan) ], week.map(&:first)
    assert_equal [ "Jueves 14 de enero", "Juan Pérez", "Joven", "—", "17 años" ], report.send(:rows, week, with_weekday: true).first
    assert report.render.start_with?("%PDF-")
  end
end
