class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: "Participant", optional: true

  enum :category, { logistica: 0, companias: 1, asignaciones: 2, alertas: 3, agenda: 4, finanzas: 5, cuentas: 6, registro: 7,
                    participantes: 8, asistencia: 9 }

  CATEGORY_LABELS = { "participantes" => "Participantes", "asignaciones" => "Asignaciones", "companias" => "Compañías",
                      "agenda" => "Agenda", "registro" => "Registro", "alertas" => "Alertas", "logistica" => "Logística",
                      "finanzas" => "Finanzas", "cuentas" => "Cuentas",
                      "asistencia" => "Asistencia nocturna" }.freeze

  # Qué clase de cosa se hizo, para el ícono de cada fila y el filtro «Acción». La frase completa (quién,
  # qué y a quién) ya viene en summary; esto solo la agrupa. Las acciones que no estén aquí caen en «Otro».
  ACTION_KINDS = {
    "creo" => { label: "Creó", icon: "plus", tone: "bg-cat-green/15 text-cat-green-ink", actions: %w[created imported] },
    "edito" => { label: "Editó", icon: "pencil", tone: "bg-cat-blue/15 text-cat-blue-ink", actions: %w[updated reset] },
    "elimino" => { label: "Eliminó", icon: "trash-2", tone: "bg-cat-rose/15 text-cat-rose-ink", actions: %w[destroyed deleted] },
    "anulo" => { label: "Anuló", icon: "undo-2", tone: "bg-cat-amber/20 text-cat-amber-ink", actions: %w[voided] },
    "staff" => { label: "Movió staff", icon: "users", tone: "bg-cat-indigo/15 text-cat-indigo-ink", actions: %w[assigned_staff removed_staff] },
    "inventario" => { label: "Movió inventario", icon: "package", tone: "bg-cat-teal/15 text-cat-teal-ink", actions: %w[stock_added stock_removed] }
  }.freeze
  OTHER_KIND = { label: "Otro", icon: "dot", tone: "bg-canvas text-ink-500" }.freeze

  PERIODS = { "hoy" => "Hoy", "ayer" => "Ayer", "semana" => "Últimos 7 días", "mes" => "Últimos 30 días" }.freeze

  validates :actor_name, :action, :category, :summary, presence: true

  scope :recent, -> { order(created_at: :desc, id: :desc) }
  scope :by_category, ->(category) { where(category: category) if categories.key?(category.to_s) }
  scope :by_kind, ->(kind) { where(action: ACTION_KINDS.dig(kind.to_s, :actions)) if ACTION_KINDS.key?(kind.to_s) }
  scope :in_period, ->(period) {
    today = Time.zone.today
    case period.to_s
    when "hoy" then where(created_at: today.all_day)
    when "ayer" then where(created_at: (today - 1).all_day)
    when "semana" then where(created_at: (today - 6).beginning_of_day..)
    when "mes" then where(created_at: (today - 29).beginning_of_day..)
    end
  }
  # Quién lo hizo, a quién o qué, o lo que dice la frase («anulo», «cuarto», el nombre de una compañía),
  # sin importar tildes ni mayúsculas. translate() en vez de la extensión unaccent: nada que instalar.
  ACCENTS = [ "áéíóúüñÁÉÍÓÚÜÑ", "aeiouunaeiouun" ].freeze
  scope :search, ->(query) {
    next if query.blank?

    plain = ->(column) { "translate(lower(coalesce(#{column}, '')), '#{ACCENTS[0]}', '#{ACCENTS[1]}')" }
    term = "%#{sanitize_sql_like(I18n.transliterate(query.strip).downcase)}%"
    where(%w[actor_name target_name summary].map { |column| "#{plain.(column)} LIKE :q" }.join(" OR "), q: term)
  }

  def category_label
    CATEGORY_LABELS.fetch(category, category)
  end

  def kind
    ACTION_KINDS.find { |_, meta| meta[:actions].include?(action) }&.last || OTHER_KIND
  end
end
