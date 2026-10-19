# El interruptor de Configuración con el que dirección abre o cierra a los consejeros su compañía: mientras
# está cerrada, cada consejero sabe que ya tiene compañero(a) y ve su compañía en cifras (cuántos jóvenes,
# edades, estacas y barrios), pero no los nombres ni las fichas de nadie. Lo mueven el superadmin, el
# matrimonio director y los coordinadores (User#company_reveal_manager?). Vive en AppSetting, sin tabla.
module CompanyReveal
  KEY = "companias_abiertas_a_consejeros".freeze

  def self.open?
    AppSetting[KEY] == "1"
  end

  def self.open!
    AppSetting[KEY] = "1"
  end

  def self.close!
    AppSetting[KEY] = "0"
  end

  ACTIONS = %w[companies_opened companies_closed].freeze

  # Quién lo movió por última vez y cuándo (su entrada de Historial), para la línea de Configuración.
  def self.last_change
    AuditLog.where(action: ACTIONS).recent.first
  end

  # El aviso a todos los consejeros cuando se abre: ya pueden conocer a su compañía.
  def self.announce!(sender:, sender_name:)
    Alert.create!(title: "¡Ya puedes conocer a tu compañía!",
                  body: "Dirección abrió las compañías: ya ves a tu compañero(a) y a los jóvenes que vas a cuidar.",
                  audience: :por_roles, target_roles: [ "consejero" ], priority: :importante,
                  sender: sender, sender_name: sender_name, link_path: "/mi-compania")
  end
end
