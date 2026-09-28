# Una persona del archivo de una carga masiva. Las limpias entran directo (imported). Las que traen un
# problema o un aviso quedan en espera (pending), fuera de la base: se corrigen, y entran solo cuando
# alguien las aprueba (approved), o se descartan (discarded). Las reglas viven en ImportRowEvaluator.
class ParticipantImportRow < ApplicationRecord
  belongs_to :participant_import
  belongs_to :participant, optional: true

  enum :status, { imported: 0, pending: 1, approved: 2, discarded: 3 }

  STATUS_LABELS = { "imported" => "Entró", "pending" => "Por resolver", "approved" => "Aprobada", "discarded" => "Descartada" }.freeze

  # Los campos que se pueden corregir a mano, con su etiqueta: los mismos que reconoce la carga.
  EDITABLE = {
    first_name: "Nombres", last_name: "Apellidos", age: "Edad", gender: "Sexo", stake: "Estaca", ward: "Barrio",
    shirt_number: "Talla", rol: "Rol", identity_document: "Cédula", company_number: "Compañía",
    auxiliar_company: "Compañía auxiliar", room: "Cuarto", phone_number: "Teléfono", email_address: "Correo",
    emergency_contact_name: "Contacto de emergencia", emergency_contact_number: "Teléfono de emergencia",
    emergency_contact_relation: "Parentesco", allergies: "Alergias", medicines: "Medicinas", diet: "Dieta",
    additional_instructions: "Notas"
  }.freeze

  def evaluator
    ImportRowEvaluator.new(values)
  end

  def name
    [ values["first_name"], values["last_name"] ].compact_blank.join(" ").presence || "sin nombre"
  end

  def blocking?
    issues.any? { |issue| issue["blocking"] }
  end

  def status_label
    STATUS_LABELS.fetch(status, status)
  end

  # Las fichas con las que choca, para abrirlas y comparar.
  def matches
    ids = issues.filter_map { |issue| issue["match_id"] }.uniq
    Participant.where(id: ids).index_by(&:id)
  end

  # Vuelve a revisar la fila con sus datos actuales (tras editarla, o porque la base cambió).
  def reevaluate!
    update!(issues: evaluator.evaluate.issues)
  end

  # Entra a la base si ya no tiene nada que la bloquee. by: quien aprueba (nombre para el informe).
  def approve!(by_name)
    evaluation = evaluator
    participant = evaluation.apply!
    unless participant
      update!(issues: evaluation.issues)
      return false
    end

    update!(status: :approved, participant: participant, issues: evaluation.issues,
            resolved_by_name: by_name, resolved_at: Time.current)
  end

  def discard!(by_name)
    update!(status: :discarded, resolved_by_name: by_name, resolved_at: Time.current)
  end
end
