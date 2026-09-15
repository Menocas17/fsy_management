class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update destroy assign_staff remove_staff]
  before_action :require_company_edit!, only: %i[edit update destroy assign_staff remove_staff]

  FIELD_LABELS = { "name" => "nombre", "auxiliar_company_id" => "compañía auxiliar" }.freeze
  ROLE_LABELS = { "consejero" => "consejero", "auxiliar" => "auxiliar", "participant" => "joven" }.freeze

  def index
    @auxiliar_companies = AuxiliarCompany.includes(companies: :auxiliar_company).order(:name)
    @orphan_companies = Company.where(auxiliar_company_id: nil).order(:name)
  end

  def show
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      record_audit!(category: :companias, action: "created", target: @company, summary: "Creó la compañía #{@company.name}")
      redirect_to @company, notice: "Compañía creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      fields = changed_field_labels(@company, FIELD_LABELS)
      if fields.any?
        record_audit!(category: :companias, action: "updated", target: @company,
                      summary: "Actualizó #{spanish_list(fields)} de la compañía #{@company.name}")
      end
      redirect_to @company, notice: "Compañía actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    record_audit!(category: :companias, action: "destroyed", target: @company, summary: "Eliminó la compañía #{@company.name}")
    redirect_to companies_path, status: :see_other, notice: "Compañía eliminada."
  end

  def overview
    @auxiliar_companies = AuxiliarCompany.includes(:companies, :counselors, :auxiliars).order(:name)
    @companies = Company.includes(:counselors, :auxiliars, :participants, :auxiliar_company).order(:name)
    @orphan_companies = Company.where(auxiliar_company_id: nil)
  end

  def assign_staff
    @membership = @company.memberships.build(membership_params)
    if @membership.save
      record_audit!(category: :companias, action: "assigned_staff", target: @company,
                    summary: "Asignó a #{@membership.participant.full_name} como #{ROLE_LABELS.fetch(@membership.role, @membership.role)} en #{@company.name}")
      redirect_to @company, notice: "Personal asignado."
    else
      flash[:alert] = @membership.errors.full_messages.to_sentence
      redirect_to @company
    end
  end

  def remove_staff
    membership = @company.memberships.includes(:participant).find(params[:membership_id])
    membership.destroy
    record_audit!(category: :companias, action: "removed_staff", target: @company,
                  summary: "Removió a #{membership.participant.full_name} de #{@company.name}")
    redirect_to @company, notice: "Personal removido."
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.expect(company: [ :name, :auxiliar_company_id ])
    end

    def membership_params
      params.permit(:participant_id)
    end
end
