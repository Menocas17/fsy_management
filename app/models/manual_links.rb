# Los enlaces a la Biblioteca del Evangelio de la página de Manuales: los ve todo el mundo y solo el superadmin
# los cambia. Viven en AppSetting, sin tabla; sin enlace guardado, el de siempre (la música, ninguno: no sale).
module ManualLinks
  LINKS = {
    "predicad" => { title: "Predicad Mi Evangelio", subtitle: "Guía para el servicio misional", icon: "book", tone: :blue,
                    default: "https://www.churchofjesuschrist.org/study/manual/preach-my-gospel-2023?lang=spa" },
    "fortaleza" => { title: "Para la Fortaleza de la Juventud", subtitle: "Una guía para tomar decisiones", icon: "shield-check", tone: :indigo,
                     default: "https://www.churchofjesuschrist.org/study/manual/for-the-strength-of-youth?lang=spa" },
    "musica" => { title: "Música de FSY", subtitle: "Las canciones del FSY", icon: "music-2", tone: :amber, default: nil }
  }.freeze

  def self.setting_key(key)
    "manual_link_#{key}"
  end

  def self.url(key)
    stored = AppSetting[setting_key(key)]
    stored.nil? ? LINKS.fetch(key)[:default] : stored.presence
  end

  # Los que tienen enlace, en orden: { key:, title:, subtitle:, icon:, tone:, url: }.
  def self.all
    LINKS.filter_map { |key, link| (url = self.url(key)) && link.merge(key: key, url: url) }
  end

  # Solo direcciones web completas; vacío quita el enlace. Devuelve las claves que no se pudieron guardar.
  def self.update(params)
    LINKS.keys.select { |key| params.key?(key) }.reject do |key|
      value = params[key].to_s.strip
      next false unless value.empty? || value.match?(%r{\Ahttps?://\S+\z})

      AppSetting[setting_key(key)] = value
      true
    end
  end
end
