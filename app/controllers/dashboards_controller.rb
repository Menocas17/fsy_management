class DashboardsController < ApplicationController
  def show
    @dashboard = DashboardFacade.new(user: Current.user)
    # En el modo simple el teléfono ve un inicio corto; «Ver todas las estadísticas» (?completo=1) abre el de siempre.
    @simple = helpers.simple_mode? && params[:completo].blank?
  end
end
