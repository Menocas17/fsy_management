module ParticipantsHelper
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
