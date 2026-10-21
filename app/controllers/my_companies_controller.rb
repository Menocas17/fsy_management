# «Mi compañía» del joven: su número y nombre elegido, sus consejeros, su comedor y cuarto, y sus compañeros
# solo por nombre (sus fichas son de sus consejeros). A los demás los lleva a la página de la suya. Antes de que
# se finalice el registro, «Próximamente» y lo que verá entonces.
class MyCompaniesController < ApplicationController
  allow_jovenes
  def show
    @participant = Current.user.participant
    return redirect_to(helpers.my_company_link || dashboard_path) unless @participant&.joven?

    # Hasta que se finaliza el registro, «Próximamente» (CompanyReveal): ni su compañía ni si ya tiene una.
    @coming_soon = Current.user.company_coming_soon?
    return if @coming_soon

    @company = @participant.company
    return unless @company

    @summary = CompanySummary.new(@company)
    @counselors = @company.counselors_in_order
    @companions = @company.participants.where.not(id: @participant.id).order(:first_name, :last_name).to_a
  end
end
