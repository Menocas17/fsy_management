class AuxiliarCompaniesController < ApplicationController
  before_action :set_auxiliar_company, only: %i[show edit update destroy assign_staff remove_staff]
  before_action :require_company_edit!, only: %i[edit update destroy assign_staff remove_staff]

  def index
    @auxiliar_companies = AuxiliarCompany.includes(:coordinator).order(:name)
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
      redirect_to @auxiliar_company, notice: "Compañía auxiliar creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @auxiliar_company.update(auxiliar_company_params)
      redirect_to @auxiliar_company, notice: "Compañía auxiliar actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @auxiliar_company.destroy
    redirect_to auxiliar_companies_path, status: :see_other, notice: "Compañía auxiliar eliminada."
  end

  def assign_staff
    @membership = @auxiliar_company.memberships.build(membership_params)
    if @membership.save
      redirect_to @auxiliar_company, notice: "Personal asignado."
    else
      flash[:alert] = @membership.errors.full_messages.to_sentence
      redirect_to @auxiliar_company
    end
  end

  def remove_staff
    membership = @auxiliar_company.memberships.find(params[:membership_id])
    membership.destroy
    redirect_to @auxiliar_company, notice: "Personal removido."
  end

  private
    def set_auxiliar_company
      @auxiliar_company = AuxiliarCompany.find(params[:id])
    end

    def auxiliar_company_params
      params.expect(auxiliar_company: [ :name, :coordinator_id ])
    end

    def membership_params
      params.permit(:participant_id)
    end
end
