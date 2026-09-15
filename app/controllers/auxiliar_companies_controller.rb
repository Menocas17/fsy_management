class AuxiliarCompaniesController < ApplicationController
  before_action :set_auxiliar_company, only: %i[show edit update destroy assign_staff remove_staff]
  before_action :require_company_edit!, only: %i[edit update destroy assign_staff remove_staff]

  FIELD_LABELS = { "name" => "nombre", "coordinator_id" => "coordinador", "second_coordinator_id" => "segundo coordinador" }.freeze

  def index
    @auxiliar_companies = AuxiliarCompany.includes(:coordinator, :second_coordinator).order(:name)
  end

  def show
    @companies = @auxiliar_company.companies.includes(:auxiliar_company)
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
      redirect_to @auxiliar_company, notice: "Personal asignado."
    else
      flash[:alert] = @membership.errors.full_messages.to_sentence
      redirect_to @auxiliar_company
    end
  end

  def remove_staff
    membership = @auxiliar_company.memberships.includes(:participant).find(params[:membership_id])
    membership.destroy
    record_audit!(category: :companias, action: "removed_staff", target: @auxiliar_company,
                  summary: "Removió a #{membership.participant.full_name} de la compañía auxiliar #{@auxiliar_company.name}")
    redirect_to @auxiliar_company, notice: "Personal removido."
  end

  private
    def set_auxiliar_company
      @auxiliar_company = AuxiliarCompany.find(params[:id])
    end

    def auxiliar_company_params
      params.expect(auxiliar_company: [ :name, :coordinator_id, :second_coordinator_id ])
    end

    def membership_params
      params.permit(:participant_id)
    end
end
