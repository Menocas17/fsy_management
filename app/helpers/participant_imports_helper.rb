module ParticipantImportsHelper
  # Opciones para corregir un campo de lista. Si lo que trajo el archivo no es ninguna opción válida
  # («Bello Orizonte»), se muestra igual, marcado, para que se vea qué había y se elija la correcta.
  def import_select_options(options, current)
    known = options.any? { |label, value| [ label, value ].map { |v| ImportRowEvaluator.normalize(v) }.include?(ImportRowEvaluator.normalize(current)) }
    extra = current.present? && !known ? [ [ "#{current} (del archivo, no válido)", current ] ] : []
    selected = options.find { |label, value| [ label, value ].map { |v| ImportRowEvaluator.normalize(v) }.include?(ImportRowEvaluator.normalize(current)) }&.last || current
    options_for_select([ [ "—", "" ] ] + extra + options, selected)
  end

  def import_field_options(field)
    case field
    when :gender then [ [ "Hombre", "H" ], [ "Mujer", "M" ] ]
    when :stake then Participant.stakes.keys.map { |key| [ key.titleize, key ] }
    when :ward then Participant.wards.keys.map { |key| [ key.titleize, key ] }
    when :shirt_number then Participant.shirt_numbers.keys.map { |key| [ key.upcase, key ] }
    when :rol then Participant.rols.keys.map { |key| [ Participant.role_label(key), key ] }
    when :auxiliar_company then AuxiliarCompany.order(:name).map { |auxiliar| [ auxiliar.name, auxiliar.name ] }
    end
  end
end
