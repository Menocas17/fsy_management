# Una carga masiva con su informe: quién entró directo, quién espera a que se resuelva a mano y qué se
# descartó. Queda guardada para volver a verla (ver ParticipantImportRow).
class ParticipantImport < ApplicationRecord
  belongs_to :uploaded_by, class_name: "Participant", optional: true
  has_many :rows, -> { order(:row_number) }, class_name: "ParticipantImportRow", dependent: :destroy

  scope :recent, -> { order(created_at: :desc) }

  def counts
    @counts ||= rows.unscope(:order).group(:status).count
  end

  def count_of(status)
    counts[status.to_s].to_i
  end

  def pending_count = count_of(:pending)
  def entered_count = count_of(:imported) + count_of(:approved)
end
