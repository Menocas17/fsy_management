require "test_helper"

class CareNoteTest < ActiveSupport::TestCase
  test "a phrase that only says everything is fine is nothing to attend" do
    [ "Ninguna", "Todo bien", "todo está bien.", "Normal", "Todo es normal", "Dieta normal", "Como de todo",
      "Como de todo tipo de comida", "No tengo ninguna alergia", "No padezco de ninguna enfermedad", "N/A",
      "Estoy bien gracias a Dios", "Me siento bien emocionalmente", "Normal, sin alergias", "Ninguna y sin alergias" ].each do |text|
      assert CareNote.nothing_to_attend?(text), "«#{text}» should be nothing to attend"
    end
  end

  test "anything that says something real stays, even next to a «todo bien»" do
    [ "Asma", "No como cerdo", "Alergia a la penicilina", "Vegetariano", "Ansiedad", "Me siento triste a veces",
      "Ninguna, pero usa inhalador", "Todo bien, excepto el asma", "No tengo alergias pero tomo pastillas",
      "Normal y vegetariano", "", nil ].each do |text|
      refute CareNote.nothing_to_attend?(text), "«#{text}» should stay"
    end
  end
end
