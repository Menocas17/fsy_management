# Borra de las fichas la información médica, de dieta o emocional que solo dice que todo está bien
# (CareNote): «Todo bien», «Como de todo», «Normal». Lo corre `bin/rails datos:depurar_atencion`, que primero
# solo muestra qué borraría y qué frases cortas se quedan, por si alguna también dice «todo bien».
class CareNoteCleanup
  # Las que se quedan y miden hasta esto se muestran: lo largo ya es información de verdad.
  SHORT = 40

  attr_reader :cleared, :kept, :changes

  def initialize
    @cleared = Hash.new { |hash, key| hash[key] = Hash.new(0) }
    @kept = Hash.new { |hash, key| hash[key] = Hash.new(0) }
    @changes = []
    scan
  end

  # Lo que se queda corto de un campo, el más repetido primero: [[texto, fichas], …].
  def short_kept(field)
    kept[field].select { |text, _| text.length <= SHORT }.sort_by { |text, count| [ -count, text ] }
  end

  def cleared_in(field)
    cleared[field].sort_by { |text, count| [ -count, text ] }
  end

  def run
    return 0 if changes.empty?

    Participant.transaction do
      changes.each { |participant, info| participant.update_column(:medical_info, info) }
      AuditLog.create!(actor_name: "Administrador del sistema", action: "updated", category: :participantes,
                       summary: "Borró «todo bien» y frases parecidas de la información médica, de dieta o emocional de #{changes.size} fichas")
    end
    changes.size
  end

  private
    def scan
      Participant.where.not(medical_info: nil).find_each do |participant|
        info = participant.medical_info.to_h
        fields = CareNote::FIELDS.keys.select { |field| info[field].present? && CareNote.nothing_to_attend?(info[field]) }
        CareNote::FIELDS.each_key do |field|
          next if info[field].blank?

          (fields.include?(field) ? cleared : kept)[field][info[field].to_s.strip] += 1
        end
        changes << [ participant, info.merge(fields.index_with(nil)) ] if fields.any?
      end
    end
end
