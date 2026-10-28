# El reparto de jóvenes en compañías, con los mismos principios (y los mismos pesos) que el sugeridor
# (CompanySuggester): la edad manda, después el balance de hombres y mujeres, que los de un mismo barrio se repartan
# en compañías distintas y que nadie quede con un consejero de su barrio; a igualdad, compañías del mismo tamaño.
# Arma una propuesta sin guardar nada; Plan#apply! la guarda en participants.company_id.
#
# Dos modos:
# - pendientes (el de siempre): solo los jóvenes sin compañía, en las compañías que ya hay, sin mover a nadie. Cada
#   uno va a donde el sugeridor lo pondría, sin pasar del tamaño parejo (todos los jóvenes entre todas las compañías).
# - todos: rehace el reparto entero en `companies` compañías y crea las que falten (numeradas después de la última).
#   Ordena a las mujeres por edad y las corta en tantos tramos como compañías, lo mismo a los hombres, y la compañía 1
#   recibe el tramo más joven de cada uno; después intercambia jóvenes del mismo género entre compañías cercanas
#   mientras baje el costo, sobre todo para separar a los del mismo barrio.
#
# «Reordenar» es otra semilla: cambia el orden en que se reparten e intercambian. La misma semilla da siempre la
# misma propuesta, y la primera (sin semilla) va en el orden natural.
class CompanyPlanner
  MODES = %w[pendientes todos].freeze
  # Cuántos jóvenes por compañía se proponen al armarlas desde cero.
  TARGET_SIZE = 20
  TRIALS = 6
  PASSES = 8
  # Con qué compañías se intercambia: hasta cinco más allá (las de edad parecida).
  REACH = 5

  W = CompanySuggester

  Member = Struct.new(:id, :name, :age, :gender, :ward, :company_id, keyword_init: true)

  # Una compañía de la propuesta: la que ya existe (company) o la que se crearía (solo number).
  class Bucket
    attr_reader :company, :number, :counselor_wards, :members

    def initialize(company: nil, number: nil, counselor_wards: [], members: [])
      @company = company
      @number = company&.number || number
      @counselor_wards = counselor_wards
      @members = members
    end

    def new? = company.nil?
    def name = company&.name || "Compañía #{number}"
    def size = members.size
    def women = members.count { |member| member.gender == "M" }
    def men = members.count { |member| member.gender == "H" }

    def age_range
      ages = members.filter_map(&:age)
      ages.empty? ? nil : ages.minmax
    end

    # Los que comparten barrio con otro de la compañía.
    def repeated_wards
      members.filter_map(&:ward).tally.values.select { |count| count > 1 }.sum
    end

    def counselor_ward_conflicts
      members.count { |member| member.ward && counselor_wards.include?(member.ward) }
    end

    def cost = CompanyPlanner.cost(members, counselor_wards)
  end

  class Plan
    attr_reader :mode, :seed, :buckets, :placed, :unplaced, :warnings

    def initialize(mode:, seed:, buckets:, placed:, unplaced:, warnings:)
      @mode = mode
      @seed = seed
      @buckets = buckets
      @placed = placed
      @unplaced = unplaced
      @warnings = warnings
    end

    def score = @score ||= buckets.sum(&:cost)
    def placed_count = placed.size
    def new_companies = buckets.select(&:new?)
    def repeated_wards = buckets.sum(&:repeated_wards)
    def counselor_ward_conflicts = buckets.sum(&:counselor_ward_conflicts)

    # La compañía de cada joven que la propuesta mueve o ubica.
    def moves
      @moves ||= buckets.flat_map { |bucket| bucket.members.map { |member| [ member, bucket ] } }
                        .reject { |member, bucket| bucket.company && member.company_id == bucket.company.id }
    end

    # Crea las compañías nuevas y guarda la compañía de cada joven. Devuelve cuántas fichas cambiaron.
    def apply!
      now = Time.current
      Participant.transaction do
        ids = buckets.to_h { |bucket| [ bucket, bucket.company&.id || Company.create!(number: bucket.number).id ] }
        moves.group_by(&:last).sum do |bucket, pairs|
          Participant.joven.where(id: pairs.map { |member, _| member.id }).update_all(company_id: ids[bucket], updated_at: now)
        end
      end
    end
  end

  # Lo que pesa una compañía con estos jóvenes (menos es mejor), con los pesos del sugeridor: lejos de la edad del
  # medio y edades de más de dos años seguidos, el desbalance de géneros, cada par del mismo barrio, cada joven con
  # un consejero de su barrio y, a lo último, lo que se aleja del tamaño parejo.
  def self.cost(members, counselor_wards, target: nil)
    ages = members.filter_map(&:age).sort
    age = 0
    if ages.any?
      middle = ages[ages.size / 2]
      age = ages.sum { |value| (value - middle).abs } * W::AGE_FROM_MIDDLE + [ ages.last - ages.first - 1, 0 ].max * W::AGE_OUTSIDE
    end
    women = members.count { |member| member.gender == "M" }
    gender = (women - (members.size - women)).abs * W::GENDER_GAP
    wards = members.filter_map(&:ward).tally.values.sum { |count| count * (count - 1) / 2 } * W::SAME_WARD
    counselors = members.count { |member| member.ward && counselor_wards.include?(member.ward) } * W::COUNSELOR_WARD
    size = target ? (members.size - target).abs * W::SIZE : 0
    age + gender + wards + counselors + size
  end

  def self.jovenes
    Participant.joven.order(:birth_date, :last_name, :first_name, :id)
               .select(:id, :first_name, :last_name, :birth_date, :age, :gender, :ward, :company_id).to_a
  end

  # Lo que leyó el reparto, resumido: si cambia entre la vista previa y aplicarla, se vuelve a mostrar.
  def self.fingerprint
    jovenes = self.jovenes.map { |joven| [ joven.id, joven.company_id, joven.birth_date, joven.age, joven.gender, joven.ward ] }
    companies = Company.order(:id).pluck(:id, :number)
    counselors = Membership.where(associable_type: "Company", role: "consejero").joins(:participant)
                           .order(:associable_id, :participant_id).pluck(:associable_id, "participants.ward")
    Digest::SHA256.hexdigest([ jovenes, companies, counselors ].to_json)[0, 16]
  end

  # Cuántas compañías propone el modo «todos»: las que ya hay o, sin ninguna, una por cada TARGET_SIZE jóvenes.
  def self.default_company_count
    Company.any? ? Company.count : [ (Participant.joven.count / TARGET_SIZE.to_f).ceil, 1 ].max
  end

  def initialize(mode: "pendientes", seed: nil, companies: nil)
    @mode = MODES.include?(mode.to_s) ? mode.to_s : "pendientes"
    @seed = seed&.to_i
    @company_count = companies.to_i.positive? ? companies.to_i : nil
  end

  def call
    @members = self.class.jovenes.map do |joven|
      Member.new(id: joven.id, name: joven.full_name, age: joven.age, gender: joven.gender, ward: joven.ward, company_id: joven.company_id)
    end
    @companies = Company.by_number.to_a
    @counselor_wards = Membership.where(associable_type: "Company", role: "consejero").joins(:participant)
                                 .pluck(:associable_id, "participants.ward").each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(company_id, ward), map|
      map[company_id] << ward if ward
    end
    @mode == "todos" ? rebuild : fill
  end

  private
    def random(index = 0)
      Random.new((@seed || 0) * 1_000 + index)
    end

    # Solo los que no tienen compañía, cada uno donde el sugeridor lo pondría sin pasar del tamaño parejo.
    def fill
      return empty_plan("Todavía no hay compañías: créalas o usa «Rehacer todo».") if @companies.empty?

      pending = @members.select { |member| member.company_id.nil? }
      cap = (@members.size / @companies.size.to_f).ceil
      attempts = Array.new(TRIALS) do |index|
        buckets = @companies.map do |company|
          Bucket.new(company: company, counselor_wards: @counselor_wards[company.id],
                     members: @members.select { |member| member.company_id == company.id })
        end
        order = @seed.nil? && index.zero? ? pending : pending.shuffle(random: random(index))
        order.each { |member| best_bucket(buckets, member, cap).members << member }
        buckets
      end
      buckets = attempts.min_by { |candidate| candidate.sum(&:cost) }
      Plan.new(mode: @mode, seed: @seed, buckets: buckets, placed: pending, unplaced: [], warnings: [])
    end

    # Como el sugeridor: una compañía todavía sin jóvenes no tiene edad, y pesa AGE_UNKNOWN.
    def best_bucket(buckets, member, cap)
      open = buckets.select { |bucket| bucket.size < cap }
      open = buckets.select { |bucket| bucket.size == buckets.map(&:size).min } if open.empty?
      open.min_by do |bucket|
        delta = self.class.cost(bucket.members + [ member ], bucket.counselor_wards) - bucket.cost
        delta += W::AGE_UNKNOWN if bucket.members.none?(&:age) && member.age
        [ delta + bucket.size * W::SIZE, bucket.number || 0 ]
      end
    end

    # Todo de nuevo: tramos de edad por género y después intercambios entre compañías cercanas.
    def rebuild
      count = @company_count || self.class.default_company_count
      warnings = []
      kept = @companies.first(count)
      last_number = @companies.filter_map(&:number).max || 0
      buckets = kept.map { |company| Bucket.new(company: company, counselor_wards: @counselor_wards[company.id]) }
      buckets += (1..(count - kept.size)).map { |offset| Bucket.new(number: last_number + offset) } if count > kept.size
      left_empty = @companies.drop(count)
      warnings << "#{left_empty.map(&:name).to_sentence(two_words_connector: " y ", last_word_connector: " y ")} " \
                  "#{left_empty.one? ? "queda" : "quedan"} sin jóvenes." if left_empty.any?

      rng = random
      middle = @members.filter_map(&:age).sort.then { |ages| ages[ages.size / 2] }
      women = @members.select { |member| member.gender == "M" }
      men = @members.select { |member| member.gender == "H" }
      others = @members - women - men
      deal(women, buckets, middle, rng, larger_first: true)
      deal(men, buckets, middle, rng, larger_first: false)
      deal(others, buckets, middle, rng, larger_first: true) if others.any?
      improve(buckets, rng)
      Plan.new(mode: @mode, seed: @seed, buckets: buckets, placed: @members, unplaced: [], warnings: warnings)
    end

    # Por edad, en tramos parejos: el más joven a la compañía 1. Si no se reparten exacto, los tramos con uno de más
    # van al principio para un género y al final para el otro, así las compañías quedan del mismo tamaño.
    def deal(members, buckets, middle, rng, larger_first:)
      sorted = members.sort_by { |member| [ member.age || middle || 0, (@seed ? rng.rand : 0), member.name ] }
      base, extra = sorted.size.divmod(buckets.size)
      sizes = Array.new(buckets.size) { |index| base + ((larger_first ? index < extra : index >= buckets.size - extra) ? 1 : 0) }
      buckets.zip(sizes).each { |bucket, size| bucket.members.concat(sorted.shift(size)) }
    end

    # Intercambia dos jóvenes del mismo género entre compañías cercanas (REACH) cuando baja el costo de las dos.
    # Mismo género: el balance no cambia. El costo se calcula por diferencia (Tally), no compañía entera: son
    # cientos de miles de pruebas, y en el 0.1 de CPU de Render cada milisegundo aquí son diez allá.
    def improve(buckets, rng)
      tallies = buckets.to_h { |bucket| [ bucket, Tally.new(bucket) ] }
      PASSES.times do
        swapped = false
        pairs = (0...buckets.size).flat_map { |index| (1..REACH).filter_map { |step| [ index, index + step ] if index + step < buckets.size } }
        pairs.shuffle!(random: rng) if @seed
        pairs.each do |first, second|
          left, right = tallies[buckets[first]], tallies[buckets[second]]
          left.bucket.members.dup.each do |a|
            b = right.bucket.members.find { |other| other.gender == a.gender && left.gain(a, other) + right.gain(other, a) < 0 }
            next unless b

            left.swap(a, b)
            right.swap(b, a)
            swapped = true
          end
        end
        break unless swapped
      end
    end

    # Lo que cuenta una compañía para saber, sin recorrerla, cuánto cambia su costo si sale `out` y entra `into`.
    class Tally
      attr_reader :bucket

      def initialize(bucket)
        @bucket = bucket
        @wards = bucket.members.filter_map(&:ward).tally
        @ages = bucket.members.filter_map(&:age).tally
        ages = bucket.members.filter_map(&:age).sort
        @middle = ages[ages.size / 2]
        @counselors = bucket.counselor_wards
      end

      def gain(out, into)
        return 0 if out.ward == into.ward && out.age == into.age

        ward_gain(out, into) + counselor_gain(out, into) + age_gain(out, into)
      end

      def swap(out, into)
        @bucket.members[@bucket.members.index(out)] = into
        bump(@wards, out.ward, -1)
        bump(@wards, into.ward, 1)
        bump(@ages, out.age, -1)
        bump(@ages, into.age, 1)
      end

      private
        W = CompanySuggester

        def ward_gain(out, into)
          return 0 if out.ward == into.ward

          gone = out.ward ? @wards.fetch(out.ward, 0) - 1 : 0
          added = into.ward ? @wards.fetch(into.ward, 0) : 0
          (added - gone) * W::SAME_WARD
        end

        def counselor_gain(out, into)
          ((@counselors.include?(into.ward) ? 1 : 0) - (@counselors.include?(out.ward) ? 1 : 0)) * W::COUNSELOR_WARD
        end

        def age_gain(out, into)
          return 0 if @middle.nil? || out.age == into.age

          distance = ->(age) { age ? (age - @middle).abs : 0 }
          (distance.(into.age) - distance.(out.age)) * W::AGE_FROM_MIDDLE + (spread_after(out.age, into.age) - spread_after(nil, nil)) * W::AGE_OUTSIDE
        end

        # Los años de más del rango de edades (más de dos años seguidos), si sale una edad y entra otra.
        def spread_after(gone, added)
          ages = @ages.dup
          bump(ages, gone, -1)
          bump(ages, added, 1)
          ages.empty? ? 0 : [ ages.keys.max - ages.keys.min - 1, 0 ].max
        end

        def bump(tally, key, step)
          return if key.nil?

          tally[key] = tally.fetch(key, 0) + step
          tally.delete(key) if tally[key].zero?
        end
    end

    def empty_plan(warning)
      Plan.new(mode: @mode, seed: @seed, buckets: [], placed: [], unplaced: @members.select { |member| member.company_id.nil? }, warnings: [ warning ])
    end
end
