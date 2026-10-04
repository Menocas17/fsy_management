# La ficha de enfermería de un joven: lo que ya dice su ficha (alergias, medicinas, contacto de emergencia) y
# cada visita con sus notas. Todo el staff la abre; las notas solo las leen quienes deben (can_read_infirmary_notes?).
class InfirmaryChartsController < ApplicationController
  include InfirmaryChart

  before_action :require_infirmary_viewer!

  def show
    load_infirmary_chart(Participant.jovenes.find(params[:participant_id]))
    @note = InfirmaryNote.new(kind: :nota)
  end
end
