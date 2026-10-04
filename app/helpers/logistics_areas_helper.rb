module LogisticsAreasHelper
  # Cada bandera tiene su ícono y su tono (DESIGN.md): Registro verde, Finanzas azul, Alimentación ámbar. Lo usan
  # el chip de la bandera, el mosaico de cada tarjeta de área y la explicación de arriba, para que coincidan.
  FLAG_STYLES = { checkin: [ "scan-line", :green ], finance: [ "wallet", :blue ], food: [ "utensils", :amber ] }.freeze

  def flag_style(flag)
    FLAG_STYLES.fetch(flag.to_sym)
  end

  # El mosaico de una tarjeta de área: el de su primera bandera, o gris si solo ve.
  def area_tile(area)
    flag = area.flags.first
    flag ? flag_style(flag) : [ "users", :neutral ]
  end
end
