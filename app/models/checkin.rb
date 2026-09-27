# La llegada de un joven al evento. Una por persona: escanear dos veces no vuelve a registrar,
# solo avisa que ya estaba. Se guarda cuándo llegó, que puede ser mucho antes de cuándo se sincronizó.
class Checkin < ApplicationRecord
  belongs_to :participant
  belongs_to :recorded_by, class_name: "Participant", optional: true

  enum :source, { qr: 0, manual: 1 }, prefix: true

  validates :participant_id, uniqueness: true
  validates :recorded_at, presence: true

  before_validation :stamp_defaults

  scope :recent, -> { order(recorded_at: :desc, created_at: :desc) }

  def self.arrived_ids
    pluck(:participant_id).to_set
  end

  # Un escaneo que llega dos veces (por reintento sin señal) no crea otra llegada.
  def self.register(participant:, recorded_by:, recorded_at: nil, source: :qr, client_token: nil)
    existing = find_by(participant: participant) || (client_token.present? && find_by(client_token: client_token))
    return [ existing, :already ] if existing

    checkin = create!(participant: participant, recorded_by: recorded_by,
                      recorded_at: recorded_at || Time.current, source: source, client_token: client_token)
    [ checkin, :registered ]
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    # Dos dispositivos escaneando a la misma persona a la vez: gana el primero y el otro ve "ya estaba".
    [ find_by(participant: participant), :already ]
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
