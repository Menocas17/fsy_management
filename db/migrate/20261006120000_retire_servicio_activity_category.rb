# En FSY no hay servicio comunitario: la categoría «Servicio» de la agenda se retira y lo que la tenía pasa a
# «Actividad». Su número (4) queda sin usar, como el del rol registrador.
class RetireServicioActivityCategory < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE activities SET category = 3 WHERE category = 4"
  end

  def down
  end
end
