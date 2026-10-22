# Las compañías sugeridas (CompanySuggester) para un joven sin compañía. En el formulario se piden con lo que
# va escrito (fecha de nacimiento, género, barrio) y «Elegir» llena el campo; en la ficha (modo=ficha) salen
# con lo guardado y «Asignar» la guarda.
class CompanySuggestionsController < ApplicationController
  before_action -> { head :forbidden unless can_suggest_company? }
  before_action :require_company_revealed!

  def show
    @participant = Participant.joven.find_by(id: params[:participant_id]) if params[:participant_id].present?
    @profile = params[:modo] == "ficha" && @participant.present?
    @suggestions = CompanySuggester.new(age: requested_age, gender: params[:genero].presence_in(%w[M H]) || @participant&.gender,
                                        ward: params[:barrio].presence_in(Participant.wards.keys) || @participant&.ward,
                                        exclude: @participant).call
  end

  private
    # La fecha como se escribe en el formulario (14/03/2010) o en ISO; sin ella, la edad de la ficha.
    def requested_age
      text = params[:fecha].to_s.strip
      date = [ "%d/%m/%Y", "%Y-%m-%d" ].lazy.filter_map { |format| Date.strptime(text, format) rescue nil }.first if text.present?
      return Participant.new(birth_date: date).age_on(Date.current) if date && date < Date.current

      @participant&.age
    end
end
