# Buscar en toda la app (GlobalSearch). Cualquiera con sesión puede usarla (ver es de todos); el botón vive
# en la barra inferior del modo simple de quien ve todo el evento (User#global_searcher?).
class SearchesController < ApplicationController
  def show
    @query = params[:q].to_s.squish
    @kind = params[:tipo] if GlobalSearch::KINDS.key?(params[:tipo])
    @search = GlobalSearch.new(@query, user: Current.user)
  end
end
