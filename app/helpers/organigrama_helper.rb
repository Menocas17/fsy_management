module OrganigramaHelper
  # Versión del organigrama general para su caché, en una consulta: cambia si cambia cualquier ficha (nombres,
  # fotos, cuántos jóvenes tiene cada compañía), quién está en qué compañía, o una compañía o un área.
  def self.version
    ActiveRecord::Base.connection.select_rows(<<~SQL).first.join("/")
      SELECT (SELECT COUNT(*) || '-' || COALESCE(MAX(updated_at)::text, '') FROM participants),
             (SELECT COUNT(*) || '-' || COALESCE(MAX(updated_at)::text, '') FROM memberships),
             (SELECT COUNT(*) || '-' || COALESCE(MAX(updated_at)::text, '') FROM companies),
             (SELECT COUNT(*) || '-' || COALESCE(MAX(updated_at)::text, '') FROM auxiliar_companies),
             (SELECT COUNT(*) || '-' || COALESCE(MAX(updated_at)::text, '') FROM logistics_areas)
    SQL
  end

  # Los datos de organigrama/_general, cargados desde la vista (dentro de su bloque de caché) para que una
  # visita con la caché llena no consulte nada de esto. Ambas ramas cuelgan de la pareja de directores; la
  # vista de logística deja solo esa rama.
  def load_general_organigrama
    @directors = Participant.director.with_attached_avatar.order(:gender, :first_name)
    @jovenes_counts = Participant.jovenes.where.not(company_id: nil).group(:company_id).count
    @show_companies = @view == "todo"
    @show_logistics = true

    if @show_companies
      @coordinators = Participant.coordinador.with_attached_avatar.order(:gender, :first_name)
      @auxiliar_companies = AuxiliarCompany.includes(auxiliars: Participant::AVATAR_PRELOAD, companies: { counselors: Participant::AVATAR_PRELOAD })
                                           .sort_by { |auxiliar_company| [ auxiliar_company.first_company_number || Float::INFINITY, auxiliar_company.name ] }
      @orphan_companies = Company.where(auxiliar_company_id: nil).includes(counselors: Participant::AVATAR_PRELOAD).by_number
    end

    @logistics_directors = Participant.director_logistica.with_attached_avatar.order(:gender, :first_name)
    @logistics = Participant.logistica.includes(:logistics_area).with_attached_avatar.order(:first_name, :last_name)
  end
end
