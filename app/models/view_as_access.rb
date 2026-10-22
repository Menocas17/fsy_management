# «Ver como» es del superadmin, pero él puede prestarlo, con un interruptor por grupo en Configuración, al
# matrimonio director, al matrimonio director de logística y a los coordinadores (User#view_as_allowed?). Con
# él encendido ven la app como cualquier rol o ficha de staff, igual que el superadmin, y también solo miran
# (ViewAsReadOnly); nunca como la cuenta del superadmin. Vive en AppSetting, sin tabla.
module ViewAsAccess
  GROUPS = {
    "director" => "Matrimonio director",
    "director_logistica" => "Matrimonio director de logística",
    "coordinador" => "Coordinadores"
  }.freeze

  def self.key(rol)
    "ver_como_#{rol}"
  end

  def self.enabled?(rol)
    GROUPS.key?(rol.to_s) && AppSetting[key(rol)] == "1"
  end

  def self.set!(rol, enabled)
    AppSetting[key(rol)] = enabled ? "1" : "0"
  end
end
