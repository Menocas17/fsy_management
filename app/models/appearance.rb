# Icono y color para identificar algo de un vistazo (un inventario, una categoría de gasto). Los iconos son
# de Lucide (app/assets/svg/icons/lucide/outline): la clave es el nombre del archivo y el valor, lo que se
# lee al elegir. Los colores llevan el icono en blanco encima, así que todos tienen contraste para eso.
module Appearance
  ICON_GROUPS = {
    "Dinero" => {
      "wallet" => "Billetera", "banknote" => "Efectivo", "coins" => "Monedas", "piggy-bank" => "Ahorro",
      "hand-coins" => "Pagos", "credit-card" => "Tarjeta", "receipt" => "Facturas", "calculator" => "Cuentas"
    },
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

  COLORS = {
    "primary" => "Azul marino", "blue" => "Azul", "sky" => "Celeste", "teal" => "Verde azulado",
    "green" => "Verde", "lime" => "Lima", "amber" => "Ámbar", "orange" => "Naranja", "brown" => "Café",
    "rose" => "Rojo", "pink" => "Rosado", "indigo" => "Índigo", "violet" => "Morado", "slate" => "Gris"
  }.freeze

  # La clase de fondo de cada color, en texto literal para que Tailwind la genere.
  COLOR_CLASSES = {
    "primary" => "bg-primary-600", "blue" => "bg-cat-blue", "sky" => "bg-sky-600", "teal" => "bg-cat-teal",
    "green" => "bg-cat-green", "lime" => "bg-lime-600", "amber" => "bg-cat-amber", "orange" => "bg-orange-600",
    "brown" => "bg-amber-800", "rose" => "bg-cat-rose", "pink" => "bg-pink-600", "indigo" => "bg-cat-indigo",
    "violet" => "bg-violet-600", "slate" => "bg-slate-600"
  }.freeze

  def self.color_class(color)
    COLOR_CLASSES.fetch(color.to_s, COLOR_CLASSES["primary"])
  end
end
