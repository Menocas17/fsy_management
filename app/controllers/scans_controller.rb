# El lector de QR del panel. Los gafetes llevan la URL de la ficha y las cajas el código del artículo;
# aquí se decide a dónde lleva lo que se leyó.
class ScansController < ApplicationController
  def show
  end

  def lookup
    code = params[:code].to_s.strip.split("/").last.to_s.split("?").first.to_s

    if (participant = Participant.find_by_badge(code))
      redirect_to participant_path(participant, from: "escaner", return_to: scan_path)
    elsif can_view_inventory? && (item = InventoryItem.find_by(code: code.upcase))
      redirect_to inventory_item_path(item, ajuste: 1, origen: "escaneo")
    else
      redirect_to scan_path, alert: "Ese código no es de ningún gafete#{" ni artículo" if can_view_inventory?} del sistema."
    end
  end
end
