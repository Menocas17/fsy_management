# La hoja de instalar la app (shared/_install_sheet_dialog). install_controller.js la pide cuando va a abrirla, en
# vez de que viaje en el HTML de cada página. También sale en la pantalla de entrar, antes de iniciar sesión.
class InstallSheetsController < ApplicationController
  allow_unauthenticated_access

  def show
    render partial: "shared/install_sheet_dialog"
  end
end
