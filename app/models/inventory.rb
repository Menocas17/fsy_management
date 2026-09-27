class Inventory < ApplicationRecord
  has_many :items, -> { order(:name) }, class_name: "InventoryItem", dependent: :destroy
  has_many :movements, through: :items

  # Los iconos son de Lucide (app/assets/svg/icons/lucide/outline): la clave es el nombre del archivo y
  # el valor, lo que se lee en el formulario. Van agrupados como se muestran al elegir.
  ICON_GROUPS = {
    "Almacén" => {
      "package" => "Paquete", "boxes" => "Cajas", "archive" => "Archivo", "backpack" => "Mochilas",
      "gift" => "Regalos", "ticket" => "Boletos", "key" => "Llaves", "lock" => "Candados"
    },
    "Comida y bebida" => {
      "utensils" => "Cubiertos", "coffee" => "Café", "cup-soda" => "Bebidas", "droplets" => "Agua",
      "apple" => "Fruta", "sandwich" => "Sándwiches", "cookie" => "Galletas"
    },
    "Salud" => {
      "pill" => "Medicinas", "heart-pulse" => "Salud", "bandage" => "Curitas", "stethoscope" => "Enfermería",
      "thermometer" => "Termómetro", "syringe" => "Inyecciones"
    },
    "Limpieza y aseo" => {
      "sparkles" => "Limpieza", "spray-can" => "Desinfectante", "bath" => "Aseo personal", "trash-2" => "Basura",
      "umbrella" => "Paraguas", "sun" => "Protector solar"
    },
    "Ropa y hospedaje" => {
      "shirt" => "Camisetas", "tent" => "Campamento", "bed-double" => "Camas", "sofa" => "Muebles",
      "lamp" => "Lámparas", "flashlight" => "Linternas"
    },
    "Electrónica y audio" => {
      "monitor" => "Pantallas", "laptop" => "Computadoras", "tv" => "Televisores", "projector" => "Proyector",
      "printer" => "Impresora", "camera" => "Cámara", "mic" => "Micrófonos", "speaker" => "Parlantes",
      "headphones" => "Audífonos", "cable" => "Cables", "plug" => "Extensiones", "battery" => "Baterías",
      "lightbulb" => "Bombillos"
    },
    "Música" => {
      "music" => "Música", "guitar" => "Guitarras", "piano" => "Teclados", "drum" => "Percusión"
    },
    "Papelería" => {
      "book-open" => "Libros", "notebook-pen" => "Cuadernos", "pencil" => "Lápices", "scissors" => "Tijeras",
      "ruler" => "Reglas", "paintbrush" => "Pinceles", "palette" => "Pinturas", "sticky-note" => "Notas",
      "clipboard-list" => "Listas", "folder" => "Carpetas", "file-text" => "Documentos"
    },
    "Herramientas" => {
      "wrench" => "Herramientas", "hammer" => "Martillos", "drill" => "Taladros", "paint-roller" => "Rodillos"
    },
    "Deportes y actividades" => {
      "volleyball" => "Deportes", "dumbbell" => "Pesas", "trophy" => "Trofeos", "medal" => "Medallas",
      "flag" => "Banderas", "gamepad-2" => "Juegos", "puzzle" => "Rompecabezas", "dices" => "Dados",
      "map" => "Mapas", "compass" => "Brújulas"
    },
    "Otros" => {
      "bus" => "Transporte", "truck" => "Carga", "church" => "Capilla", "hand-heart" => "Servicio",
      "heart" => "Corazón", "star" => "Estrella"
    }
  }.freeze
  ICONS = ICON_GROUPS.values.reduce(:merge).freeze

  # La clase de cada color vive en InventoryHelper::INVENTORY_COLORS. Todos llevan el icono en blanco
  # encima, así que son tonos con contraste suficiente para eso.
  COLORS = {
    "primary" => "Azul marino", "blue" => "Azul", "sky" => "Celeste", "teal" => "Verde azulado",
    "green" => "Verde", "lime" => "Lima", "amber" => "Ámbar", "orange" => "Naranja", "brown" => "Café",
    "rose" => "Rojo", "pink" => "Rosado", "indigo" => "Índigo", "violet" => "Morado", "slate" => "Gris"
  }.freeze

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :code_prefix, presence: true, uniqueness: { case_sensitive: false },
                          format: { with: /\A[A-Z]{2,5}\z/, message: "usa de 2 a 5 letras mayúsculas" }
  validates :icon, inclusion: { in: ICONS.keys }
  validates :color, inclusion: { in: COLORS.keys }

  before_validation :derive_code_prefix, on: :create

  scope :by_name, -> { order(:name) }

  def low_stock_items
    items.select(&:low?)
  end

  def out_of_stock_items
    items.select(&:out?)
  end

  # El historial y el audit log piden un nombre legible.
  alias_attribute :to_s, :name

  private
    # "Medicinas" → MED; si ya existe, MEDI, MEDIC… hasta encontrar uno libre.
    def derive_code_prefix
      return if code_prefix.present?

      letters = name.to_s.unicode_normalize(:nfd).gsub(/[^A-Za-z]/, "").upcase
      return if letters.blank?

      candidate = letters.first(3)
      candidate = letters.first(candidate.length + 1) while Inventory.exists?(code_prefix: candidate) && candidate.length < 5
      self.code_prefix = candidate
    end
end
