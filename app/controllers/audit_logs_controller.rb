class AuditLogsController < ApplicationController
  before_action :require_staff_manager!

  # Lo que cada fila puede enlazar: si el registro sigue existiendo, su nombre lleva a él.
  LINKABLE = %w[Participant Company AuxiliarCompany LogisticsArea Inventory InventoryItem Alert Expense Activity].freeze
  FILTERS = %i[query category kind period].freeze

  def index
    @pagy, @audit_logs = pagy(AuditLog.includes(actor: :avatar_attachment)
                                      .by_category(params[:category])
                                      .by_kind(params[:kind])
                                      .in_period(params[:period])
                                      .search(params[:query])
                                      .recent)
    @targets = load_targets(@audit_logs)
    @filtered = FILTERS.any? { |key| params[key].present? }
  end

  private
    # Una consulta por tipo, no una por fila.
    def load_targets(logs)
      logs.select { |log| LINKABLE.include?(log.target_type) && log.target_id }
          .group_by(&:target_type)
          .flat_map { |type, group| type.constantize.where(id: group.map(&:target_id)).to_a }
          .index_by { |record| [ record.class.name, record.id ] }
    end
end
