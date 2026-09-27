class ReportsController < ApplicationController
  before_action :require_reports_access!
  before_action :require_participant_reports!, only: %i[participants rooms agenda badges]
  before_action :require_logistics_reports!, only: %i[inventory labels]

  def index
  end

  def participants
    send_report ParticipantsReport.new(scope: params[:scope])
  end

  def rooms
    send_report RoomsReport.new
  end

  def agenda
    send_report AgendaReport.new
  end

  # El QR de cada gafete abre la ficha del participante, igual que el del perfil.
  def badges
    send_report BadgeLabelsReport.new(scope: params[:scope], company: Company.find_by(id: params[:company]),
                                      qr_url: ->(participant) { participant_url(participant) })
  end

  def inventory
    send_report InventoryReport.new(inventory: requested_inventory)
  end

  def labels
    send_report InventoryLabelsReport.new(inventory: requested_inventory)
  end

  private
    # Sin inventario en la URL, el reporte sale con todos.
    def requested_inventory
      Inventory.find_by(id: params[:inventory])
    end

    # Inline para que el PDF se abra en el navegador y se imprima de una vez.
    def send_report(report)
      send_data report.render, filename: report.filename, type: "application/pdf", disposition: "inline"
    end
end
