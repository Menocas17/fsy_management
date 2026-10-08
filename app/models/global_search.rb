# La búsqueda de toda la app (SearchesController, el botón central del modo simple): personas, compañías,
# artículos del inventario y estacas o barrios, sin importar tildes ni mayúsculas. Cada grupo trae unos pocos
# resultados y cuántos hay en total; los módulos del menú los agrega la vista (dependen de las rutas).
class GlobalSearch
  KINDS = {
    "personas" => "Personas", "companias" => "Compañías", "inventario" => "Inventario",
    "estacas" => "Estacas y barrios", "modulos" => "Módulos"
  }.freeze
  LIMIT = 8
  MIN_LENGTH = 2

  Group = Struct.new(:records, :total)

  def self.normalize(text)
    I18n.transliterate(text.to_s).downcase.squish
  end

  def initialize(query, user:)
    @query = query.to_s.squish
    @user = user
  end

  def searchable?
    @query.length >= MIN_LENGTH
  end

  def people
    @people ||= group(Participant.search_full_name(@query).includes(:company, Participant::AVATAR_PRELOAD).order(:first_name, :last_name))
  end

  # Las compañías (por número, nombre, nombre elegido o consejero) y las compañías auxiliares por su nombre.
  def companies
    @companies ||= begin
      companies = Company.search(@query).includes(:auxiliar_company).by_number
      auxiliars = AuxiliarCompany.where("name ILIKE ?", "%#{AuxiliarCompany.sanitize_sql_like(@query)}%").order(:name)
      Group.new(companies.limit(LIMIT).to_a + auxiliars.limit(3).to_a, companies.count + auxiliars.count)
    end
  end

  # Solo para quien entra al inventario: a los demás un artículo no les abriría nada.
  def inventory_items
    @inventory_items ||= @user.inventory_member? ? group(InventoryItem.search(@query).includes(:inventory).by_name) : Group.new([], 0)
  end

  # Estacas y barrios por su nombre: [:stake | :ward, clave, nombre].
  def places
    @places ||= begin
      term = self.class.normalize(@query)
      matches = Participant::STAKE_LABELS.map { |key, label| [ :stake, key, label ] } +
                Participant::WARD_LABELS.map { |key, label| [ :ward, key, label ] }
      found = matches.select { |_, _, label| self.class.normalize(label).include?(term) }
      Group.new(found.first(LIMIT), found.size)
    end
  end

  private
    def group(scope)
      Group.new(scope.limit(LIMIT).to_a, scope.count)
    end
end
