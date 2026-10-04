# El rol registrador se retira: registrar jóvenes y llegadas ahora es de logística con la bandera Registro.
# Quien lo tenía pasa a logística (sin área: su director le da la que corresponda) y los avisos o
# actividades dirigidos a registradores lo dejan de nombrar. El 4 queda libre en el enum para no mover los demás.
class RetireRegistradorRole < ActiveRecord::Migration[8.1]
  REGISTRADOR = 4
  LOGISTICA = 5

  def up
    execute "UPDATE participants SET rol = #{LOGISTICA}, logistics_area_id = NULL WHERE rol = #{REGISTRADOR}"
    %w[alerts activities].each do |table|
      execute "UPDATE #{table} SET target_roles = array_remove(target_roles, 'registrador') WHERE 'registrador' = ANY(target_roles)"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
