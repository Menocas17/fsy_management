# Sugiere compañías para un joven que llega a registrarse el día del evento (sin compañía todavía). Las
# compañías se arman por edad, así que la edad pesa más que todo; después:
#
# - el balance de hombres y mujeres: mejor donde falta gente de su género;
# - cuántos de su barrio ya hay en la compañía: mejor donde hay menos, para que se mezclen;
# - el barrio de sus consejeros: mejor que ninguno sea de su mismo barrio.
#
# Devuelve las mejores primero, cada una con sus razones para que quien registra decida.
class CompanySuggester
  Reason = Struct.new(:text, :tone, keyword_init: true)
  Suggestion = Struct.new(:company, :score, :reasons, :jovenes, keyword_init: true)

  # Cuánto pesa cada cosa en el puntaje (menos es mejor).
  AGE_OUTSIDE = 100     # por cada año fuera del rango de edades de la compañía
  AGE_FROM_MIDDLE = 8   # por cada año de distancia a la edad del medio
  AGE_UNKNOWN = 60      # una compañía sin jóvenes todavía: no se sabe su edad
  GENDER_GAP = 6        # por cada uno de su género de más (o de menos, resta) frente al otro
  SAME_WARD = 10        # por cada joven de su mismo barrio
  COUNSELOR_WARD = 70   # si un consejero es de su mismo barrio
  SIZE = 1              # por cada joven: a igualdad, la compañía más chica

  def initialize(age:, gender:, ward: nil, exclude: nil)
    @age = age
    @gender = gender.presence
    @ward = ward.presence
    @exclude = exclude
  end

  def call(limit: 3)
    return [] if @age.nil? && @gender.nil?

    jovenes = Participant.joven.where.not(company_id: nil).where.not(id: @exclude&.id)
                         .select(:id, :company_id, :birth_date, :age, :gender, :ward).group_by(&:company_id)
    counselors = Membership.where(associable_type: "Company", role: "consejero").includes(:participant)
                           .group_by(&:associable_id).transform_values { |memberships| memberships.filter_map(&:participant) }
    Company.by_number.map { |company| suggest(company, jovenes.fetch(company.id, []), counselors.fetch(company.id, [])) }
           .sort_by { |suggestion| [ suggestion.score, suggestion.company.number || 0 ] }
           .first(limit)
  end

  private
    def suggest(company, jovenes, counselors)
      reasons = []
      score = age_score(jovenes, reasons) + gender_score(jovenes, reasons) + ward_score(jovenes, counselors, reasons) +
              jovenes.size * SIZE
      Suggestion.new(company: company, score: score, reasons: reasons, jovenes: jovenes.size)
    end

    def age_score(jovenes, reasons)
      return 0 if @age.nil?

      ages = jovenes.filter_map(&:age).sort
      if ages.empty?
        reasons << Reason.new(text: "Todavía sin jóvenes", tone: :neutral)
        return AGE_UNKNOWN
      end

      low, high = ages.first, ages.last
      middle = ages[ages.size / 2]
      outside = @age < low ? low - @age : [ @age - high, 0 ].max
      range = low == high ? "#{low} años" : "#{low} a #{high} años"
      reasons << Reason.new(text: outside.zero? ? "Edades de #{range}" : "Edades de #{range}: queda fuera", tone: outside.zero? ? :green : :amber)
      outside * AGE_OUTSIDE + (@age - middle).abs * AGE_FROM_MIDDLE
    end

    def gender_score(jovenes, reasons)
      return 0 if @gender.nil?

      same = jovenes.count { |joven| joven.gender == @gender }
      other = jovenes.size - same
      label = @gender == "M" ? "mujeres" : "hombres"
      counts = "#{jovenes.count { |joven| joven.gender == "M" }} M · #{jovenes.count { |joven| joven.gender == "H" }} H"
      if same < other
        reasons << Reason.new(text: "Le faltan #{label} (#{counts})", tone: :green)
      elsif same > other
        reasons << Reason.new(text: "Le sobran #{label} (#{counts})", tone: :amber)
      elsif jovenes.any?
        reasons << Reason.new(text: "Pareja (#{counts})", tone: :neutral)
      end
      (same - other) * GENDER_GAP
    end

    def ward_score(jovenes, counselors, reasons)
      return 0 if @ward.nil?

      peers = jovenes.count { |joven| joven.ward == @ward }
      reasons << Reason.new(text: peers.zero? ? "Nadie de su barrio" : "#{peers} de su barrio", tone: peers.zero? ? :green : :amber)
      same_ward = counselors.select { |counselor| counselor.ward == @ward }
      if same_ward.any?
        reasons << Reason.new(text: "#{same_ward.map(&:first_name).to_sentence(two_words_connector: " y ", last_word_connector: " y ")}, " \
                                    "#{same_ward.one? ? "consejero" : "consejeros"} de su barrio", tone: :rose)
      end
      peers * SAME_WARD + (same_ward.any? ? COUNSELOR_WARD : 0)
    end
end
