class DashboardsController < ApplicationController
  def show
    @dashboard = DashboardFacade.new(user: Current.user)
    # En el modo simple el teléfono ve un inicio corto; el panel entero queda en la computadora.
    @simple = helpers.simple_mode?
  end
end
