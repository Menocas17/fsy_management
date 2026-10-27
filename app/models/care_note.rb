# Lo que un joven escribe en información médica, dieta o información emocional para decir que no hay nada que
# atender: «Todo bien», «Como de todo», «No tengo ninguna alergia», «Estoy bien gracias a Dios». No es
# información: la carga masiva lo deja en blanco (el informe de la carga guarda el texto original) y
# `bin/rails datos:depurar_atencion` lo borra de las fichas que ya están, así los filtros de cocina y salud
# solo cuentan a quien de verdad hay que atender. Se compara la frase entera: «No como cerdo» o «Ninguna, pero
# usa inhalador» se quedan.
module CareNote
  FIELDS = { "medical_information" => "Información médica", "diet" => "Dieta",
             "emotional_information" => "Información emocional" }.freeze

  THING = "(alergias?|enfermedad(es)?|condicion(es)?|problemas?|restriccion(es)?|dietas?|medicamentos?|medicinas?|" \
          "padecimientos?|complicaciones?|cuidados?|necesidad(es)?|informacion|tratamientos?)"
  KIND = "(medicas?|alimenticias?|alimentarias?|de salud|especiales?|emocionales?|cronicas?|conocidas?|que reportar|que declarar)"

  # Frases enteras, ya sin acentos, mayúsculas ni signos.
  PATTERNS = [
    /\A(n|no|na|n a|nada|ninguna?|ningun|ninguno|nop|nope|negativo|no aplica|no hay|no tengo|no ninguna?|no nada|nada nada)\z/,
    /\A((todo |es |todo es |todo esta )?normal|(dieta|alimentacion|comida|salud|estado de salud) normal|bien|muy bien|todo bien|todo esta bien|todo en orden|perfecto|todo perfecto|excelente|sano|sana|saludable|estable)\z/,
    /\A(sin novedad(es)?|sin problemas?|sin nada|nada que (reportar|declarar|mencionar)|ninguna observacion)\z/,
    /\A(no|yo no) (tengo|padezco|sufro|presento|necesito|requiero|hay)( de)?( ningun tipo de| ninguna?| ningun| nada)?( #{THING})?( #{KIND})?\z/,
    /\A(ninguna?|ningun|sin) (tipo de )?#{THING}( #{KIND})?\z/,
    /\A(yo )?(estoy|me siento|me encuentro|todo|todo esta|me va) (muy )?(bien|perfecto|excelente|normal|estable|tranquilo|tranquila|saludable|sano|sana)\z/,
    /\A(yo )?como (de )?todo( tipo de (comida|alimentos))?\z/
  ].freeze

  # Lo que se agrega al final sin cambiar nada: «… gracias a Dios», «… por el momento».
  TRAILING = /( (gracias a dios|gracias|por el momento|por ahora|hasta el momento|de momento|actualmente|emocionalmente|fisicamente|de salud|todo bien))+\z/

  # Cada parte («Normal, como de todo», «Ninguna y sin alergias») tiene que decir que todo está bien.
  def self.nothing_to_attend?(text)
    parts = ImportRowEvaluator.normalize(text).split(/[,;]| y /).map { |part| part.gsub(/[^a-z0-9 ]+/, " ").squish }.reject(&:empty?)
    parts.any? && parts.all? { |part| fine?(part) }
  end

  def self.fine?(words)
    words = words.sub(TRAILING, "").presence || words
    PATTERNS.any? { |pattern| words.match?(pattern) }
  end

  # El texto, o nada si solo dice que todo está bien.
  def self.clean(text)
    text unless nothing_to_attend?(text)
  end
end
