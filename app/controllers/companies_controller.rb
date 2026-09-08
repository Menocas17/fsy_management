class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update destroy assign_staff remove_staff]
  before_action :require_company_edit!, only: %i[edit update destroy assign_staff remove_staff]

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
      redirect_to @company, notice: "Compañía creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to @company, notice: "Compañía actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
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
      redirect_to @company, notice: "Personal asignado."
    else
      flash[:alert] = @membership.errors.full_messages.to_sentence
      redirect_to @company
    end
  end

  def remove_staff
    membership = @company.memberships.find(params[:membership_id])
    membership.destroy
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
