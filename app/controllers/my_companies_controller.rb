# «Mi compañía» del joven: su número y nombre elegido, sus consejeros, su comedor y cuarto, y sus compañeros
# solo por nombre (sus fichas son de sus consejeros). A los demás los lleva a la página de la suya.
class MyCompaniesController < ApplicationController
  allow_jovenes
  def show
    @participant = Current.user.participant
    return redirect_to(helpers.my_company_link || dashboard_path) unless @participant&.joven?

    @company = @participant.company
    return unless @company

    @summary = CompanySummary.new(@company)
    @counselors = @company.counselors_in_order
    @companions = @company.participants.where.not(id: @participant.id).order(:first_name, :last_name).to_a
  end
end
