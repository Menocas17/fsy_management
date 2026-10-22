# Manuales: los PDF del FSY (Manual) y los enlaces a la Biblioteca del Evangelio (ManualLinks). El joven ve su
# manual y los enlaces; el staff también el de líderes. Subir, reemplazar o quitar un PDF es del acceso total;
# cambiar los enlaces, solo del superadmin.
class ManualsController < ApplicationController
  allow_jovenes only: %i[show read]
  before_action :set_manual, only: %i[read upload remove]
  before_action :require_manual_uploader!, only: %i[upload remove]
  before_action :require_superadmin_for_links!, only: %i[links update_links]

  def show
    @manuals = Manual.kinds_for(Current.user).map { |kind| Manual.for(kind) }
    @links = ManualLinks.all
  end

  # El lector dentro de la app (pdf_reader_controller.js, con PDF.js): el joven solo abre el suyo.
  def read
    unless Manual.kinds_for(Current.user).include?(@manual.kind)
      return redirect_to(manuals_path, alert: "Ese manual es para el staff.")
    end
    return redirect_to(manuals_path, alert: "#{@manual.title} todavía no está disponible.") unless @manual.available?

    @pdf_url = pdf_source(@manual)
  end

  def upload
    file = params[:file]
    return redirect_to(manuals_path, alert: "Elige el PDF del #{@manual.title.downcase}.") if file.blank?

    replacing = @manual.available?
    @manual.file.attach(file)
    @manual.uploaded_by_name = Current.real_user&.participant&.full_name || "Administrador del sistema"
    if @manual.save
      record_audit!(category: :manuales, action: "updated", target: nil,
                    summary: "#{replacing ? "Reemplazó" : "Subió"} el PDF del #{@manual.title.downcase}")
      redirect_to manuals_path, notice: "#{@manual.title} #{replacing ? "reemplazado" : "subido"}."
    else
      redirect_to manuals_path, alert: "#{@manual.title}: #{@manual.errors.full_messages.to_sentence}."
    end
  end

  def remove
    return redirect_to(manuals_path) unless @manual.persisted? && @manual.available?

    @manual.file.purge_later
    record_audit!(category: :manuales, action: "destroyed", target: nil, summary: "Quitó el PDF del #{@manual.title.downcase}")
    redirect_to manuals_path, status: :see_other, notice: "#{@manual.title} quitado."
  end

  def links
    @links = ManualLinks::LINKS.map { |key, link| link.merge(key: key, url: ManualLinks.url(key)) }
  end

  def update_links
    invalid = ManualLinks.update(params.fetch(:links, {}).permit(*ManualLinks::LINKS.keys).to_h)
    if invalid.any?
      titles = invalid.map { |key| ManualLinks::LINKS[key][:title] }
      return redirect_to(links_manuals_path, alert: "Revisa #{titles.to_sentence(last_word_connector: " y ")}: tiene que ser una dirección completa (https://…).")
    end

    record_audit!(category: :manuales, action: "updated", target: nil, summary: "Actualizó los enlaces a la Biblioteca del Evangelio")
    redirect_to manuals_path, notice: "Enlaces guardados."
  end

  private
    def set_manual
      @manual = Manual.for(params[:kind])
    end

    # Con R2 público el lector baja el PDF directo del bucket (pide CORS en R2, docs/deploy_render.md); sin él,
    # Rails lo pasa por su propia dirección, del mismo origen.
    def pdf_source(manual)
      if Rails.configuration.x.public_storage_url.present?
        helpers.storage_url(manual.file)
      else
        rails_storage_proxy_path(manual.file)
      end
    end

    def require_manual_uploader!
      redirect_to manuals_path, alert: "Solo el acceso total sube los manuales." unless Current.user.full_access?
    end

    def require_superadmin_for_links!
      redirect_to manuals_path, alert: "Solo el administrador cambia los enlaces." unless Current.user.superadmin?
    end
end
