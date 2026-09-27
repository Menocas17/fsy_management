# Que alguien del staff estuvo en una capacitación. Una fila por persona y capacitación:
# escanear dos veces avisa que ya estaba en vez de duplicar.
class TrainingAttendance < ApplicationRecord
  belongs_to :training
  belongs_to :participant
  belongs_to :recorded_by, class_name: "Participant", optional: true

  enum :source, { qr: 0, manual: 1 }, prefix: true

  validates :participant_id, uniqueness: { scope: :training_id }
  validates :recorded_at, presence: true

  before_validation :stamp_defaults

  scope :recent, -> { order(recorded_at: :desc, created_at: :desc) }

  # Reenviar la cola al recuperar señal no crea otra asistencia.
  def self.register(training:, participant:, recorded_by:, recorded_at: nil, source: :qr, client_token: nil)
    existing = find_by(training: training, participant: participant)
    existing ||= find_by(client_token: client_token) if client_token.present?
    return [ existing, :already ] if existing

    attendance = create!(training: training, participant: participant, recorded_by: recorded_by,
                         recorded_at: recorded_at || Time.current, source: source, client_token: client_token)
    [ attendance, :registered ]
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    # Dos dispositivos marcando a la vez: gana el primero y el otro ve "ya estaba".
    [ find_by(training: training, participant: participant), :already ]
  end

  def name
    participant&.full_name.to_s
  end

  private
    def stamp_defaults
      self.recorded_at ||= Time.current
      self.recorded_by_name = recorded_by&.full_name || "Administrador del sistema" if recorded_by_name.blank?
    end
end
