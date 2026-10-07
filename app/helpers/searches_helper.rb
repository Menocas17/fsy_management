module SearchesHelper
  # Los módulos del menú (y las páginas de la cuenta) cuyo nombre coincide, sin importar tildes.
  def search_modules(query)
    return [] if query.to_s.squish.length < GlobalSearch::MIN_LENGTH

    term = GlobalSearch.normalize(query)
    pages = nav_items.map { |item| { text: item[:text], url: item[:url], icon: item[:lucide_icon] } } +
            [ { text: "Configuración", url: settings_path, icon: "settings" }, { text: "Mi perfil", url: myprofile_participants_path, icon: "user-round" } ]
    pages.select { |page| GlobalSearch.normalize(page[:text]).include?(term) }
  end

  # Los grupos de resultados en el orden en que se muestran: [clave, nombre, registros, total].
  def search_groups(search, modules)
    [
      [ "personas", search.people.records, search.people.total ],
      [ "companias", search.companies.records, search.companies.total ],
      [ "inventario", search.inventory_items.records, search.inventory_items.total ],
      [ "estacas", search.places.records, search.places.total ],
      [ "modulos", modules, modules.size ]
    ].map { |kind, records, total| [ kind, GlobalSearch::KINDS.fetch(kind), records, total ] }.select { |*, total| total.positive? }
  end

  # Una fila de resultado: { title:, meta:, url:, icon:, tone:, participant: } (con participant va su foto).
  def search_row(kind, record)
    case kind
    when "personas"
      { title: record.full_name, meta: [ record.role_label, record.company&.name ].compact.join(" · "),
        url: participant_path(record), participant: record, chip: record.joven? ? [ "Joven", :green ] : [ "Staff", :amber ] }
    when "companias"
      if record.is_a?(AuxiliarCompany)
        { title: record.name, meta: [ "Compañía auxiliar", record.company_numbers_label&.then { |numbers| "Compañías #{numbers}" } ].compact.join(" · "),
          url: auxiliar_company_path(record), icon: "network", tone: :indigo }
      else
        { title: [ record.name, record.nickname.presence&.then { |nickname| "«#{nickname}»" } ].compact.join(" "),
          meta: record.auxiliar_company&.name || "Sin compañía auxiliar", url: company_path(record), icon: "building-2", tone: :indigo }
      end
    when "inventario"
      { title: record.name, meta: [ record.code, record.inventory.name, record.quantity_label ].join(" · "),
        url: inventory_item_path(record), icon: "package", tone: :teal }
    when "estacas"
      type, key, label = record
      { title: label, meta: type == :stake ? "Estaca · ver sus participantes" : "Barrio o rama · ver sus participantes",
        url: participants_path(type => key), icon: "map-pin", tone: :blue }
    when "modulos"
      { title: record[:text], meta: "Abrir el módulo", url: record[:url], icon: record[:icon], tone: :neutral }
    end
  end
end
