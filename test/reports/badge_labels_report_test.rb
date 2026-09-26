require "test_helper"

class BadgeLabelsReportTest < ActiveSupport::TestCase
  setup do
    @company = Company.create!(number: 3, nickname: "Guerreros")
    participants(:juan).update!(company: @company)
    Membership.create!(associable: @company, participant: participants(:maria), role: "consejero", gender: "M")
    @qr_url = ->(participant) { "https://fsy.test/participants/#{participant.id}" }
  end

  test "renders a PDF with every participant by default" do
    report = BadgeLabelsReport.new(qr_url: @qr_url)

    assert report.render.start_with?("%PDF-")
    assert_equal [ participants(:juan), participants(:maria) ].sort_by(&:id), people(report).sort_by(&:id)
    assert_match(/\Agafetes-\d{4}-\d{2}-\d{2}\.pdf\z/, report.filename)
  end

  test "the scope narrows to jóvenes or staff" do
    assert_equal [ participants(:juan) ], people(BadgeLabelsReport.new(qr_url: @qr_url, scope: "jovenes"))
    assert_equal [ participants(:maria) ], people(BadgeLabelsReport.new(qr_url: @qr_url, scope: "staff"))
    assert_equal 2, people(BadgeLabelsReport.new(qr_url: @qr_url, scope: "inventado")).size
  end

  test "a company brings its jóvenes and the staff assigned by membership" do
    outsider = Participant.create!(first_name: "Ana", last_name: "Ruiz", age: 16, stake: "villa_flor",
                                   shirt_number: "s", gender: "M", rol: :joven)
    report = BadgeLabelsReport.new(qr_url: @qr_url, company: @company)

    assert_not_includes people(report), outsider
    assert_equal 2, people(report).size
    assert_match(/\Agafetes-compania-3-/, report.filename)
  end

  test "the front label shows the company, from the participant or from the membership" do
    report = BadgeLabelsReport.new(qr_url: @qr_url)

    assert_equal "Compañía 3", report.send(:company_label, participants(:juan))
    assert_equal "Compañía 3", report.send(:company_label, participants(:maria))
  end

  test "someone without a company still gets a badge" do
    loner = Participant.create!(first_name: "Luis", last_name: "Mora", age: 40, stake: "las_americas",
                                shirt_number: "l", gender: "H", rol: :logistica)

    report = BadgeLabelsReport.new(qr_url: @qr_url)

    assert_equal "Staff FSY", report.send(:company_label, loner)
    assert_equal "Sin compañía", report.send(:company_label, participants(:juan).tap { |juan| juan.company = nil })
  end

  test "a very long name stays inside its label instead of spilling onto a new page" do
    participants(:juan).update!(first_name: "Maximiliano Alejandro José",
                                last_name: "de la Concepción Rodríguez Santamaría del Carmen")
    pdf = BadgeLabelsReport.new(qr_url: @qr_url).render

    assert_equal 1, pdf.scan(%r{/Type /Page\b}).size
  end

  private
    def people(report)
      report.send(:participants)
    end
end
