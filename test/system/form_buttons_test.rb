require "application_system_test_case"

class FormButtonsTest < ApplicationSystemTestCase
  setup do
    sign_in_as(users(:one))
    resize_to_mobile
  end

  # En el celular el botón de guardar comparte la fila con Cancelar y tiene altura fija:
  # si el texto se parte en dos líneas, se sale del botón.
  test "los botones de guardar quedan en una sola línea en el celular" do
    company = Company.create!(number: 1)

    {
      edit_company_path(company) => "button[form='company-form']",
      new_auxiliar_company_path => "button[form='auxiliar-company-form']",
      edit_participant_path(participants(:juan)) => "button[form='participant-form']",
      new_inventory_path => "button[form='inventory-form']"
    }.each do |path, selector|
      visit path
      button = find(selector)

      assert_operator text_lines(button), :<=, 1, "#{button.text.inspect} se parte en #{path}"
    end
  end

  private
    # Cuántas líneas ocupa el texto del botón, midiendo su caja contra la altura de una línea.
    def text_lines(button)
      evaluate_script(<<~JS, button)
        (function(el) {
          const range = document.createRange();
          range.selectNodeContents(el);
          const lineHeight = parseFloat(getComputedStyle(el).lineHeight);
          return Math.round(range.getBoundingClientRect().height / lineHeight);
        })(arguments[0])
      JS
    end
end
