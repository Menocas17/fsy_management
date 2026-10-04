module ParticipantsHelper
  # Los barrios de cada estaca para el selector: { "bello_horizonte" => [["Bello Horizonte B", "bello_horizonte_b"], …] }.
  def stake_ward_options
    Participant::WARDS_BY_STAKE.transform_values { |wards| wards.map { |ward| [ ward.titleize, ward ] } }
  end

  # Lo mismo que Participant.with_medical_note, para una ficha ya cargada: «Ninguna» no cuenta.
  def medical_note?(value)
    value.to_s.strip.present? && !Participant::MEDICAL_NONE.include?(value.to_s.strip.downcase)
  end

  # Solo dígitos y el «+» inicial: lo que el teléfono necesita para marcar.
  def tel_href(number)
    digits = number.to_s.gsub(/[^\d+]/, "")
    "tel:#{digits}" if digits.present?
  end
end
