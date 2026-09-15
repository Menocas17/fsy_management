class AuditLogsController < ApplicationController
  before_action :require_staff_manager!

  def index
    @pagy, @audit_logs = pagy(AuditLog.includes(actor: :avatar_attachment)
                                      .by_category(params[:category])
                                      .search(params[:query])
                                      .recent)
  end
end
