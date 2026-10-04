# Una visita de un joven a la enfermería. Empieza de dos formas: su consejero (o el auxiliar de su rama) avisa
# «lo llevo a enfermería» y queda en camino hasta que enfermería confirma la entrada, o enfermería lo ingresa
# directamente. Al entrar se avisa a sus consejeros y auxiliares; al darle de alta, solo si se va a casa o al
# hospital (InfirmaryNotifier). La ficha clínica son sus notas (InfirmaryNote), que solo se agregan.
class InfirmaryVisit < ApplicationRecord
  belongs_to :participant
  belongs_to :announced_by, class_name: "Participant", optional: true
  belongs_to :admitted_by, class_name: "Participant", optional: true
  belongs_to :discharged_by, class_name: "Participant", optional: true
  has_many :notes, -> { order(:created_at, :id) }, class_name: "InfirmaryNote", dependent: :delete_all

  enum :status, { en_camino: 0, adentro: 1, alta: 2 }
  enum :reason, { fiebre: 0, malestar: 1, lesion: 2, alergia: 3, otro: 4 }, prefix: true
  enum :disposition, { regreso: 0, casa: 1, hospital: 2 }, prefix: true

  REASON_LABELS = { "fiebre" => "Fiebre", "malestar" => "Malestar", "lesion" => "Golpe o lesión", "alergia" => "Alergia",
                    "otro" => "Otro" }.freeze
  DISPOSITION_LABELS = { "regreso" => "Volvió a su compañía", "casa" => "Se fue a casa", "hospital" => "Lo llevaron al hospital" }.freeze

  validates :reason, presence: { message: "elige el motivo" }
  validates :reason_detail, presence: { message: "escribe qué pasó" }, if: :reason_otro?
  validates :reason_detail, :discharge_notes, length: { maximum: 1000 }
  validates :disposition, presence: { message: "elige cómo salió" }, if: :alta?
  validate :only_jovenes
  validate :one_open_visit_per_joven, on: :create

  normalizes :reason_detail, :discharge_notes, with: ->(text) { text.strip.presence }

  # Cada cambio (y cada nota, que toca la visita) refresca el tablero y las fichas abiertas.
  after_commit -> { broadcast_refresh_later_to "infirmary" }

  scope :ongoing, -> { where(discharged_at: nil) }
  scope :admitted_on, ->(date) { where(admitted_at: date.all_day) }
  scope :discharged_between, ->(range) { alta.where(discharged_at: range) }

  # El consejero (o el auxiliar) avisa que lo lleva: enfermería lo ve llegar y confirma la entrada.
  def self.announce(participant, by:, reason:, detail: nil)
    new(participant: participant, status: :en_camino, reason: reason.presence, reason_detail: detail,
        announced_at: Time.current, announced_by: by, announced_by_name: name_of(by))
  end

  # Enfermería lo recibe sin aviso previo: entra de una vez.
  def self.admit_directly(participant, by:, reason:, detail: nil)
    new(participant: participant, status: :adentro, reason: reason.presence, reason_detail: detail,
        admitted_at: Time.current, admitted_by: by, admitted_by_name: name_of(by))
  end

  def self.name_of(participant)
    participant&.full_name || "Administrador del sistema"
  end

  # Guarda la visita y, si ya está adentro (ingreso directo), avisa a sus consejeros y auxiliares.
  def start
    save!
    InfirmaryNotifier.admitted(self) if adentro?
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    errors.add(:base, "#{participant.full_name} ya está en enfermería") if errors.empty?
    false
  end

  # Enfermería confirma que el joven del aviso llegó.
  def admit!(by:)
    update!(status: :adentro, admitted_at: Time.current, admitted_by: by, admitted_by_name: self.class.name_of(by))
    InfirmaryNotifier.admitted(self)
  end

  def discharge(by:, disposition:, notes: nil)
    assign_attributes(status: :alta, discharged_at: Time.current, discharged_by: by, discharged_by_name: self.class.name_of(by),
                      disposition: (disposition if self.class.dispositions.key?(disposition.to_s)), discharge_notes: notes)
    return false unless save

    InfirmaryNotifier.discharged(self)
    true
  end

  # Desde cuándo cuenta: la entrada, o el aviso mientras viene en camino.
  def started_at
    admitted_at || announced_at
  end

  def reason_label
    REASON_LABELS.fetch(reason.to_s, "Sin motivo")
  end

  def disposition_label
    DISPOSITION_LABELS[disposition.to_s]
  end

  # Quienes lo cuidan: los consejeros de su compañía y los auxiliares de su rama. A ellos les llega el aviso y
  # ellos (además de enfermería y la dirección) leen las notas.
  def care_team
    company = participant.company
    return [] if company.nil?

    (company.counselors.to_a + (company.auxiliar_company&.auxiliars.to_a)).uniq
  end

  private
    def only_jovenes
      errors.add(:participant, "solo los jóvenes pasan por la enfermería del evento") if participant && !participant.joven?
    end

    def one_open_visit_per_joven
      return if participant.nil? || alta?

      errors.add(:base, "#{participant.full_name} ya está en enfermería") if self.class.ongoing.exists?(participant_id: participant.id)
    end
end
