# Una compañía en cifras, sin nombres: cuántos jóvenes, mujeres y hombres, de qué edades y de qué estacas y
# barrios vienen. Es lo que ve el consejero mientras dirección no abra las compañías (CompanyReveal) y la
# cabecera de «Mi compañía» del joven.
class CompanySummary
  Stake = Struct.new(:name, :count, :wards, keyword_init: true)

  attr_reader :company

  def initialize(company)
    @company = company
    # Una compañía tiene una veintena de jóvenes: se cargan una vez y se cuenta en Ruby (la edad es la de hoy).
    @jovenes = company.participants.select(:id, :gender, :birth_date, :age, :stake, :ward, :other_stake, :other_ward).to_a
  end

  def total
    @jovenes.size
  end

  def women
    @jovenes.count { |joven| joven.gender == "M" }
  end

  def men
    @jovenes.count { |joven| joven.gender == "H" }
  end

  # «14–17», «15» o nil si nadie tiene edad.
  def age_range
    ages = @jovenes.filter_map(&:age)
    return if ages.empty?

    ages.min == ages.max ? ages.min.to_s : "#{ages.min}–#{ages.max}"
  end

  # Las estacas de más jóvenes primero, cada una con sus barrios (y cuántos de cada uno).
  def stakes
    @stakes ||= @jovenes.group_by { |joven| stake_label(joven) }.map { |name, jovenes|
      wards = jovenes.group_by { |joven| joven.ward_name || "Sin barrio" }.transform_values(&:size)
                     .sort_by { |ward, count| [ -count, ward ] }.to_h
      Stake.new(name: name, count: jovenes.size, wards: wards)
    }.sort_by { |stake| [ -stake.count, stake.name ] }
  end

  def wards_count
    stakes.sum { |stake| stake.wards.size }
  end

  private
    def stake_label(joven)
      Participant::STAKE_LABELS[joven.stake] || joven.other_stake.presence || "Sin estaca"
    end
end
