# db:prepare corre este archivo al crear una base nueva, también la de producción en el primer deploy.
#
# En desarrollo y pruebas carga los datos de demo (lib/demo_seed.rb). En producción no: DemoSeed borra
# participantes, compañías e inventario y crea cuentas con una contraseña que está en este repo, y además
# se niega a correr sin ALLOW_DEMO_SEED=1, así que el primer arranque fallaba en db:prepare.
if Rails.env.production?
  puts "Producción: no se cargan datos de demo. Crea el superadmin con bin/kamal console (docs/deploy_oracle.md)."
else
  DemoSeed.new.run
end
