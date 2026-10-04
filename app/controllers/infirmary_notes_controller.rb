# Agregar una nota a la ficha clínica de una visita: solo enfermería. Las notas no se editan ni se borran.
class InfirmaryNotesController < ApplicationController
  include InfirmaryChart

  before_action :require_infirmary_operator!

  def create
    visit = InfirmaryVisit.find(params[:infirmary_visit_id])
    joven = visit.participant
    return redirect_to infirmary_chart_path(joven), alert: "Confirma primero que llegó a enfermería" if visit.en_camino?

    actor = Current.user.participant
    @note = visit.notes.build(note_params.except(:doses).merge(author: actor, author_name: InfirmaryVisit.name_of(actor)))
    @note.doses_to_give = note_params[:doses]
    if @note.save_with_doses(by: actor)
      given = @note.dose_labels.presence&.then { |labels| " (#{labels.to_sentence(two_words_connector: " y ", last_word_connector: " y ")})" }
      record_audit!(category: :enfermeria, action: "created", target: joven,
                    summary: "Agregó #{@note.medication? ? "un medicamento#{given}" : "una nota"} a la ficha de enfermería de #{joven.full_name}")
      redirect_to infirmary_chart_path(joven, anchor: "visita-#{visit.id}"),
                  notice: @note.doses.any? ? "Medicamento anotado y descontado del inventario." : "Nota agregada a la ficha."
    else
      load_infirmary_chart(joven)
      @note_visit = visit
      render "infirmary_charts/show", status: :unprocessable_entity
    end
  end

  private
    def note_params
      params.expect(infirmary_note: [ :body, :medication, *InfirmaryNote::VITALS.keys, doses: [ [ :item_id, :quantity ] ] ])
    end
end
