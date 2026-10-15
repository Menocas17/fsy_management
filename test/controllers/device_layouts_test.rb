require "test_helper"

# Las listas con tabla en la compu y tarjetas en el teléfono: al teléfono que lo dice (Sec-CH-UA-Mobile: ?1, Chrome
# en Android) solo le va su versión, a todo ancho (DeviceHelper). A la compu y a quien no lo dice, las dos.
class DeviceLayoutsTest < ActionDispatch::IntegrationTest
  PHONE = { "Sec-CH-UA-Mobile" => "?1" }.freeze
  DESKTOP = { "Sec-CH-UA-Mobile" => "?0" }.freeze

  setup { sign_in_as(users(:one)) }

  test "a phone gets only the participant cards, shown at any width" do
    get participants_path, headers: PHONE

    assert_select "table", count: 0
    assert_select "turbo-frame#participants_page_1"
    assert_select ".md\\:hidden turbo-frame#participants_page_1", count: 0
    assert_includes response.headers["Vary"], "Sec-CH-UA-Mobile"
  end

  test "a computer, and a browser that does not say, keep both versions split by width" do
    [ DESKTOP, {} ].each do |headers|
      get participants_path, headers: headers

      assert_select ".hidden.md\\:block table"
      assert_select ".md\\:hidden turbo-frame#participants_page_1"
    end
  end

  test "the history and the company's jovenes follow the same rule" do
    AuditLog.create!(actor_name: "Marta Jiménez", action: "updated", category: :companias, summary: "Marta cambió Alfa")
    company = Company.create!(name: "Alfa 3")
    participants(:juan).update!(company: company)

    get audit_logs_path, headers: PHONE
    assert_select "table", count: 0
    assert_select "[data-audit-log-card]"

    get company_path(company), headers: PHONE
    assert_select "[data-participant-row]", count: 0

    get company_path(company), headers: DESKTOP
    assert_select "[data-participant-row]"
  end

  test "a phone does not get the organization chart canvas" do
    Company.create!(name: "Alfa 3", auxiliar_company: AuxiliarCompany.create!(name: "Auxiliar Alfa"))

    get organigrama_path, headers: PHONE
    assert_select "[data-controller='org-chart']", count: 0
    assert_select "[data-controller='org-branches']:not(.md\\:hidden)"

    get organigrama_path, headers: DESKTOP
    assert_select "[data-controller='org-chart']"
    assert_select "[data-controller='org-branches'].md\\:hidden"
  end
end
