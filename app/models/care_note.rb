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
  NONE = "(n|no|na|n a|nada|nin?gu[nm][aoiu]?|nungun[ao]?|nop|nope|negativo|no aplica|no hay|no tengo|no ninguna?|no nada|nada nada|none|nothing)"

  PATTERNS = [
    /\A#{NONE}\z/,
    /\A((todo |es |todo es |todo esta )?normal|(dieta|alimentacion|comida|salud|estado de salud) normal|bien|muy bien|todo bien|todo esta bien|todo en orden|perfecto|perfecta|todo perfecto|excelente|sano|sana|saludable|estable)\z/,
    /\A(sin novedad(es)?|sin problemas?|sin nada|nada que (reportar|declarar|mencionar)|ninguna observacion)\z/,
    /\A(no|yo no) (tengo|padezco|parezco|sufro|presento|necesito|requiero|hay)( de)?( ningun tipo de| ninguna?| ningun| nada)?( #{THING})?( #{KIND})?\z/,
    /\A(ninguna?|ningun|sin) (tipo de )?#{THING}( #{KIND})?\z/,
    /\A(yo )?(estoy|me siento|me encuentro|todo|todo esta|me va|soy) (muy )?(bien|perfecto|perfecta|excelente|normal|estable|tranquilo|tranquila|saludable|sano|sana|feliz|alegre)\z/,
    /\A((yo )?como (de )?todo( tipo de (comida|alimentos))?|de todo (se )?(como|come)|(puedo )?comer de todo|libre de comer cualquier cosa|como cualquier cosa|whatever)\z/,
    /\A(no tengo|sin) (ningun )?problemas? con (la )?comida\z/,
    /\Ano soy alergic[oa] a nada\z/,
    /\Ai (do not|don t|dont) have any (medical )?(conditions?|allergies|problems?)\z/,
    # Cómo se siente, que es lo que muchos contestan en la información emocional: no hay nada que atender.
    /\A(muy |bastante |perfectamente |emocionalmente )?(feliz|alegre|contento|contenta|tranquilo|tranquila|estable|emocionado|emocionada|animado|animada)\z/
  ].freeze

  # Lo que se agrega al final sin cambiar nada: «… gracias a Dios», «… por el momento».
  TRAILING = /( (gracias a dios|gracias|por el momento|por ahora|hasta ahora|hasta el momento|de momento|actualmente|emocionalmente|fisicamente|de salud|todo bien))+\z/

  # Lo que sí es para atender en la información emocional de un adulto del staff. Lo demás que escriben ahí
  # («Soltero», «Soy muy espiritual», su correo) no lo es, y la carga lo deja en blanco (concern?).
  CONCERN = /ansie|depres|trist|trastorno|panico|estres|duelo|luto|fobia|terapia|psicolog|psiquiatr|medic|tdah|deficit de atencion|
             hiperactiv|autis|asperger|bipolar|timid|introvert|reservad|sentimental|nervios|insegur|autoestima|llor|crisis|
             diagnostic|tratamiento|sensib|miedo|aislad|solitari|enoj|ira\b|agresiv|traum|abuso|acoso|bullying|falleci|
             divorci|separad|condicion|apoyo|ayuda|dificultad|me cuesta|tiroid/x

  # Cada parte («Normal, como de todo», «Ninguna y sin alergias») tiene que decir que todo está bien. Un texto
  # sin ninguna letra ni número («.», «-») tampoco dice nada.
  def self.nothing_to_attend?(text)
    parts = ImportRowEvaluator.normalize(text).split(/[,;]| y /).map { |part| part.gsub(/[^a-z0-9 ]+/, " ").squish }.reject(&:empty?)
    parts.all? { |part| fine?(part) }
  end

  # Si la información emocional de alguien del staff menciona algo que atender (ansiedad, un tratamiento…).
  def self.concern?(text)
    ImportRowEvaluator.normalize(text).match?(CONCERN)
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
