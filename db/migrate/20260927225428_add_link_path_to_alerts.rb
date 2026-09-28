class AddLinkPathToAlerts < ActiveRecord::Migration[8.1]
  def change
    # A dónde lleva la alerta (la campanita y el push): p. ej. el gasto que espera aprobación.
    add_column :alerts, :link_path, :string
  end
end
