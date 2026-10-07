# Una novedad de la app, leída de config/changelog.yml (la más nueva arriba). No vive en la base: se escribe junto
# con el cambio que anuncia y sale con el mismo despliegue.
class ChangelogEntry
  FILE = Rails.root.join("config/changelog.yml")
  # La última anunciada; las que están encima de ella en el archivo son las que faltan.
  ANNOUNCED_KEY = "changelog_announced_id"

  attr_reader :id, :date, :title, :summary, :changes, :roles

  def initialize(id:, date:, title:, summary:, changes: [], roles: [])
    @id = id.to_s
    @date = date.is_a?(Date) ? date : Date.parse(date.to_s)
    @title = title
    @summary = summary
    @changes = Array(changes)
    @roles = Array(roles).map(&:to_s)
  end

  def self.all(file = FILE)
    YAML.safe_load_file(file, permitted_classes: [ Date ]).to_a.map { |attrs| new(**attrs.symbolize_keys) }
  end

  # Las que le tocan a una persona; la cuenta sin ficha (el superadmin) las ve todas, como en la campanita.
  def self.visible_to(participant, entries = all)
    entries.select { |entry| entry.for?(participant) }
  end

  # Anuncia en la campanita las novedades que todavía no se anunciaron, de la más vieja a la más nueva. La primera
  # vez (sin registro) solo la más nueva: el resto del archivo ya lo conocía todo el mundo.
  def self.announce_pending!(entries = all)
    return [] if entries.empty?

    last_id = AppSetting[ANNOUNCED_KEY]
    # Si la última anunciada ya no está en el archivo tampoco se sabe cuáles faltan: solo la más nueva.
    pending = entries.any? { |entry| entry.id == last_id } ? entries.take_while { |entry| entry.id != last_id } : entries.first(1)
    pending.reverse_each(&:announce!)
    AppSetting[ANNOUNCED_KEY] = entries.first.id
    pending
  end

  def for?(participant)
    participant.nil? || roles.empty? || roles.include?(participant.rol.to_s)
  end

  def announce!
    Alert.create!(
      title: "Novedades: #{title}".truncate(120),
      body: summary,
      audience: roles.empty? ? :todos : :por_roles,
      target_roles: roles,
      priority: :informativa,
      source: :novedades,
      link_path: "/novedades##{anchor}",
      sender_name: "Novedades de la app"
    )
  end

  def anchor
    "novedad-#{id}"
  end
end
