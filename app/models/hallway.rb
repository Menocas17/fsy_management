# Un pasillo del hotel con sus cuartos en el orden en que se recorren (el primero y el último son sus
# extremos). El ordenamiento de cuartos (RoomPlanner) llena los pasillos en orden: primero los de mujeres,
# después los de hombres; gender lo fija a mano, y sin él lo decide el ordenamiento.
class Hallway < ApplicationRecord
  has_many :rooms, -> { order(:position, :number) }, dependent: :destroy, inverse_of: :hallway
  accepts_nested_attributes_for :rooms, allow_destroy: true

  enum :gender, { M: 0, H: 1 }, prefix: :for

  GENDER_LABELS = { "M" => "Mujeres", "H" => "Hombres" }.freeze
  # Con tantos cuartos o más, un pasillo se crea largo: lleva un cuarto de consejeros en cada extremo.
  LONG_FROM = 12
  # Lo más que se crea de una vez desde el formulario («17-32, 40»).
  MAX_NEW_ROOMS = 120
  LAYOUT_FILE = Rails.root.join("config/hotel_las_mercedes.yml")

  # Los cuartos que se agregan desde el formulario del pasillo, escritos como «17-32, 40» o «017-032».
  attr_accessor :new_rooms, :new_rooms_capacity

  validates :name, presence: true, length: { maximum: 30 }, uniqueness: { case_sensitive: false }
  validate :new_rooms_are_valid
  normalizes :name, with: ->(value) { value.to_s.strip }

  after_save :create_new_rooms

  scope :ordered, -> { order(:position, :name) }

  # «17-32, 40» → ["17", …, "32", "40"]. Un rango conserva los ceros de su primer número: «017-032» → «017»…
  def self.parse_numbers(text)
    text.to_s.split(/[,;\s]+/).compact_blank.flat_map do |token|
      if (match = token.match(/\A(\d+)-(\d+)\z/))
        width = match[1].length
        Range.new(match[1].to_i, match[2].to_i).first(MAX_NEW_ROOMS + 1).map { |number| number.to_s.rjust(width, "0") }
      else
        [ token ]
      end
    end
  end

  # Carga los pasillos del hotel del evento (config/hotel_las_mercedes.yml). Solo cuando no hay ninguno: no
  # pisa lo que ya se configuró a mano.
  def self.load_layout!
    return 0 if exists?

    layout = YAML.load_file(LAYOUT_FILE)
    transaction do
      layout.fetch("hallways").each_with_index do |(name, numbers), index|
        numbers = parse_numbers(numbers)
        create!(name: name, position: index + 1, long: numbers.size >= LONG_FROM,
                new_rooms: numbers.join(","), new_rooms_capacity: Room::DEFAULT_CAPACITY)
      end
    end
    count
  end

  def self.layout_name
    YAML.load_file(LAYOUT_FILE).fetch("name")
  end

  def gender_label
    GENDER_LABELS[gender] || "Automático"
  end

  def beds
    rooms.reject(&:purpose_fuera_de_uso?).sum(&:capacity)
  end

  private
    def parsed_new_rooms
      @parsed_new_rooms ||= self.class.parse_numbers(new_rooms)
    end

    def new_rooms_are_valid
      return if new_rooms.blank?

      if parsed_new_rooms.size > MAX_NEW_ROOMS
        errors.add(:base, "Son demasiados cuartos de una vez (máximo #{MAX_NEW_ROOMS})")
      elsif (bad = parsed_new_rooms.find { |number| number.length > Room::NUMBER_MAX })
        errors.add(:base, "«#{bad}» no parece un número de cuarto")
      elsif (taken = Room.where(number: parsed_new_rooms).pluck(:number)).any? || parsed_new_rooms.uniq.size < parsed_new_rooms.size
        repeated = taken.presence || parsed_new_rooms.tally.select { |_, count| count > 1 }.keys
        errors.add(:base, "Ya existe#{"n" if repeated.size > 1} #{repeated.size == 1 ? "el cuarto" : "los cuartos"} #{repeated.first(5).join(", ")}")
      end
      capacity = new_rooms_capacity.presence&.to_i || Room::DEFAULT_CAPACITY
      errors.add(:base, "Las camas por cuarto van de 1 a #{Room::MAX_CAPACITY}") unless capacity.between?(1, Room::MAX_CAPACITY)
    end

    def create_new_rooms
      return if new_rooms.blank?

      capacity = new_rooms_capacity.presence&.to_i || Room::DEFAULT_CAPACITY
      start = rooms.maximum(:position).to_i
      parsed_new_rooms.each_with_index do |number, index|
        rooms.create!(number: number, capacity: capacity, position: start + index + 1)
      end
      self.new_rooms = nil
      @parsed_new_rooms = nil
    end
end
