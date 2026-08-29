class DashboardsController < ApplicationController
  def show
    @dashboard = DashboardFacade.new
  end
end
