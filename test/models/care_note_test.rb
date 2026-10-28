require "test_helper"

class CareNoteTest < ActiveSupport::TestCase
  test "a phrase that only says everything is fine is nothing to attend" do
    [ "Ninguna", "Todo bien", "todo está bien.", "Normal", "Todo es normal", "Dieta normal", "Como de todo",
      "Como de todo tipo de comida", "No tengo ninguna alergia", "No padezco de ninguna enfermedad", "N/A",
      "Estoy bien gracias a Dios", "Me siento bien emocionalmente", "Normal, sin alergias", "Ninguna y sin alergias",
      # Lo que trae el consolidado de consejeros: inglés, erratas, signos sueltos y cómo se sienten.
      "None.", "Ninguni", "Ningumo", "Nunguna", ".", "-", "I do not have any medical condition", "No parezco de nada",
      "De todo se come", "De todo como", "Libre de comer cualquier cosa", "No tengo problema con la comida", "Whatever",
      "No soy alérgica a nada", "Feliz", "Alegre", "Estable hasta ahora", "Emocionalmente estable", "Perfecta",
      "Perfectamente estable", "", nil ].each do |text|
      assert CareNote.nothing_to_attend?(text), "«#{text}» should be nothing to attend"
    end
  end

  test "anything that says something real stays, even next to a «todo bien»" do
    [ "Asma", "No como cerdo", "Alergia a la penicilina", "Vegetariano", "Ansiedad", "Me siento triste a veces",
      "Ninguna, pero usa inhalador", "Todo bien, excepto el asma", "No tengo alergias pero tomo pastillas",
      "Normal y vegetariano", "No tengo ninguna solo gripe", "Bastante sentimental" ].each do |text|
      refute CareNote.nothing_to_attend?(text), "«#{text}» should stay"
    end
  end

  test "in a staff member's emotional information only what is there to attend counts" do
    [ "Ansiedad leve", "timida", "Bastante sentimental", "Trastorno de tristeza profunda", "Personalidad reservada" ].each do |text|
      assert CareNote.concern?(text), "«#{text}» is to attend"
    end
    [ "Soltero", "Alegre premium 4K", "Soy muy espiritual y me gusta fortalecer a los jovenes", "riverasolissamirisal@gmail.com",
      "M", "Espero que todo salga muy bien" ].each do |text|
      refute CareNote.concern?(text), "«#{text}» is not"
    end
  end
end
