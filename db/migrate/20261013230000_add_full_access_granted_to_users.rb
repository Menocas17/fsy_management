# Acceso total dado a dedo por el superadmin a una cuenta puntual (Accesos), además del que da el rol.
class AddFullAccessGrantedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :full_access_granted, :boolean, default: false, null: false
  end
end
