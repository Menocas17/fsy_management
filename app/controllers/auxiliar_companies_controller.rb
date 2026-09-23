class AuxiliarCompaniesController < ApplicationController
  before_action :set_auxiliar_company, only: %i[show edit update destroy assign_staff remove_staff]
  before_action :require_full_company_access!, only: %i[new create destroy]
  before_action :require_company_edit!, only: %i[edit update assign_staff remove_staff]
  before_action :require_company_staffing!, only: %i[assign_staff remove_staff]

  FIELD_LABELS = { "name" => "nombre", "coordinator_id" => "coordinador", "second_coordinator_id" => "segundo coordinador" }.freeze

  def index
    @auxiliar_companies = AuxiliarCompany.includes(auxiliars: :avatar_attachment, companies: :counselors)
                                         .sort_by { |auxiliar_company| [ auxiliar_company.first_company_number || Float::INFINITY, auxiliar_company.name ] }
    @jovenes_counts = Participant.joven.joins(:company).where.not(companies: { auxiliar_company_id: nil })
                                 .group("companies.auxiliar_company_id").count
  end

  def show
    load_auxiliars
    @companies = @auxiliar_company.companies.by_number.includes(:auxiliar_company, counselors: :avatar_attachment)
    @jovenes_counts = Company.jovenes_counts
    @room_counts = Company.room_counts
  end

  def new
    @auxiliar_company = AuxiliarCompany.new
  end

  def create
    @auxiliar_company = AuxiliarCompany.new(auxiliar_company_params)
    if @auxiliar_company.save
      record_audit!(category: :companias, action: "created", target: @auxiliar_company,
                    summary: "Creó la compañía auxiliar #{@auxiliar_company.name}")
      redirect_to @auxiliar_company, notice: "Compañía auxiliar creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_staff_options
  end

  def update
    if @auxiliar_company.update(auxiliar_company_params)
      fields = changed_field_labels(@auxiliar_company, FIELD_LABELS)
      if fields.any?
        record_audit!(category: :companias, action: "updated", target: @auxiliar_company,
                      summary: "Actualizó #{spanish_list(fields)} de la compañía auxiliar #{@auxiliar_company.name}")
      end
      redirect_to @auxiliar_company, notice: "Compañía auxiliar actualizada exitosamente."
    else
      load_staff_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @auxiliar_company.destroy
    record_audit!(category: :companias, action: "destroyed", target: @auxiliar_company,
                  summary: "Eliminó la compañía auxiliar #{@auxiliar_company.name}")
    redirect_to auxiliar_companies_path, status: :see_other, notice: "Compañía auxiliar eliminada."
  end

  def assign_staff
    @membership = @auxiliar_company.memberships.build(membership_params)
    if @membership.save
      record_audit!(category: :companias, action: "assigned_staff", target: @auxiliar_company,
                    summary: "Asignó a #{@membership.participant.full_name} en la compañía auxiliar #{@auxiliar_company.name}")
      redirect_to edit_auxiliar_company_path(@auxiliar_company, anchor: "lideres"), notice: "Personal asignado."
    else
      redirect_to edit_auxiliar_company_path(@auxiliar_company, anchor: "lideres"), alert: @membership.errors.full_messages.to_sentence
    end
  end

  def remove_staff
    membership = @auxiliar_company.memberships.includes(:participant).find(params[:membership_id])
    membership.destroy
    record_audit!(category: :companias, action: "removed_staff", target: @auxiliar_company,
                  summary: "Removió a #{membership.participant.full_name} de la compañía auxiliar #{@auxiliar_company.name}")
    redirect_to edit_auxiliar_company_path(@auxiliar_company, anchor: "lideres"), notice: "Personal removido."
  end

  private
    def set_auxiliar_company
      @auxiliar_company = AuxiliarCompany.find(params[:id])
    end

    def load_auxiliars
      @auxiliars = @auxiliar_company.auxiliars.includes(:avatar_attachment).order(gender: :desc)
    end

    # Auxiliares are the auxiliary company's own staff (1 man, 1 woman); counselors are managed per company.
    def load_staff_options
      load_auxiliars
      @companies = @auxiliar_company.companies.by_number.includes(:counselors)
      @auxiliar_membership_ids = @auxiliar_company.memberships.auxiliar.pluck(:participant_id, :id).to_h
      vacant_genders = %w[H M] - @auxiliars.map(&:gender)
      @auxiliar_candidates = Participant.auxiliar
                                        .where(gender: vacant_genders)
                                        .where.not(id: Membership.where(associable_type: "AuxiliarCompany").auxiliar.select(:participant_id))
                                        .order(:first_name, :last_name)
    end

    # Los coordinadores de la rama solo los cambia quien tiene acceso total; el auxiliar apenas la renombra.
    def auxiliar_company_params
      level = action_name == "create" ? :full : auxiliar_company_edit_level(@auxiliar_company)
      fields = level == :full ? [ :name, :coordinator_id, :second_coordinator_id ] : [ :name ]
      params.expect(auxiliar_company: fields)
    end

    def membership_params
      params.permit(:participant_id)
    end
end
