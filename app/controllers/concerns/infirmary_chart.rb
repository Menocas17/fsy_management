# Lo que necesita la ficha de enfermería de un joven (infirmary_charts/show): la abre InfirmaryChartsController
# y la vuelve a pintar InfirmaryNotesController cuando una nota no se pudo guardar.
module InfirmaryChart
  extend ActiveSupport::Concern

  private
    def load_infirmary_chart(participant)
      @participant = participant
      @visits = participant.infirmary_visits.includes(:notes)
                           .order(Arel.sql("coalesce(infirmary_visits.admitted_at, infirmary_visits.announced_at) DESC"))
      @ongoing = @visits.find { |visit| visit.discharged_at.nil? }
      @read_notes = can_read_infirmary_notes?(participant)
      @company = participant.company
    end
end
