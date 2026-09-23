class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update destroy assign_staff remove_staff]
  before_action :require_full_company_access!, only: %i[new create destroy]
  before_action :require_company_edit!, only: %i[edit update assign_staff remove_staff]
  before_action :require_company_staffing!, only: %i[assign_staff remove_staff]

  FIELD_LABELS = { "number" => "número", "nickname" => "nombre elegido", "auxiliar_company_id" => "compañía auxiliar", "dining_hall" => "comedor" }.freeze
  ROLE_LABELS = { "consejero" => "consejero", "auxiliar" => "auxiliar", "participant" => "joven" }.freeze

  def index
    @companies = Company.by_number.includes(:auxiliar_company, counselors: :avatar_attachment).search(params[:query])
    @jovenes_counts = Company.jovenes_counts
    @room_counts = Company.room_counts
    @total_companies = Company.count
  end

  def show
    load_leaders
    @rooms = @company.room_occupancy
    @jovenes_total = @company.participants.count
    @pagy, @participants = pagy(@company.participants
                                        .includes(:avatar_attachment)
                                        .search_by_name(params[:query])
                                        .order(:room, :first_name, :last_name, :id), limit: 12)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      record_audit!(category: :companias, action: "created", target: @company, summary: "Creó #{@company.name}")
      redirect_to @company, notice: "Compañía creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_staff_options
  end

  def update
    if @company.update(company_params)
      fields = changed_field_labels(@company, FIELD_LABELS)
      if fields.any?
        record_audit!(category: :companias, action: "updated", target: @company,
                      summary: "Actualizó #{spanish_list(fields)} de #{@company.name}")
      end
      redirect_to @company, notice: "Compañía actualizada exitosamente."
    else
      load_staff_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    record_audit!(category: :companias, action: "destroyed", target: @company, summary: "Eliminó #{@company.name}")
    redirect_to companies_path, status: :see_other, notice: "Compañía eliminada."
  end

  def overview
    @companies = Company.by_number.includes(:auxiliar_company, :counselors)
    @auxiliar_companies = AuxiliarCompany.includes(:companies, :auxiliars)
                                         .sort_by { |auxiliar_company| [ auxiliar_company.first_company_number || Float::INFINITY, auxiliar_company.name ] }
    @jovenes_counts = Company.jovenes_counts
    @room_counts = Company.room_counts
    @gender_counts = Participant.joven.where.not(company_id: nil).group(:company_id, :gender).count
    @dining_counts = Company.jovenes_by_dining_hall
  end

  def assign_staff
    @membership = @company.memberships.build(membership_params)
    if @membership.save
      record_audit!(category: :companias, action: "assigned_staff", target: @company,
                    summary: "Asignó a #{@membership.participant.full_name} como #{ROLE_LABELS.fetch(@membership.role, @membership.role)} en #{@company.name}")
      redirect_to edit_company_path(@company, anchor: "lideres"), notice: "Personal asignado."
    else
      redirect_to edit_company_path(@company, anchor: "lideres"), alert: @membership.errors.full_messages.to_sentence
    end
  end

  def remove_staff
    membership = @company.memberships.includes(:participant).find(params[:membership_id])
    membership.destroy
    record_audit!(category: :companias, action: "removed_staff", target: @company,
                  summary: "Removió a #{membership.participant.full_name} de #{@company.name}")
    redirect_to edit_company_path(@company, anchor: "lideres"), notice: "Personal removido."
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    # Counselors are the company's own staff; auxiliares come from its auxiliary company.
    def load_leaders
      @counselors = @company.counselors.includes(:avatar_attachment).order(gender: :desc)
      @auxiliars = @company.auxiliar_company ? @company.auxiliar_company.auxiliars.includes(:avatar_attachment).order(gender: :desc) : Participant.none
    end

    def load_staff_options
      load_leaders
      @counselor_membership_ids = @company.memberships.consejero.pluck(:participant_id, :id).to_h
      vacant_genders = %w[H M] - @counselors.map(&:gender)
      @counselor_candidates = Participant.consejero
                                         .where(gender: vacant_genders)
                                         .where.not(id: Membership.where(associable_type: "Company").consejero.select(:participant_id))
                                         .order(:first_name, :last_name)
    end

    # The company number is set once at creation and never edited afterwards; the rest depends on who is editing:
    # el consejero solo cambia el nombre elegido, el auxiliar todo salvo mover la compañía de rama.
    def company_params
      level = action_name == "create" ? :full : company_edit_level(@company)
      fields = case level
      when :full   then [ :nickname, :auxiliar_company_id, :dining_hall ]
      when :branch then [ :nickname, :dining_hall ]
      else [ :nickname ]
      end
      fields << :number if action_name == "create"
      params.expect(company: fields)
    end

    def membership_params
      params.permit(:participant_id)
    end
end
