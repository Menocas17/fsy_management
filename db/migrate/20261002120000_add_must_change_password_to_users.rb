# Las cuentas creadas desde una ficha (o restablecidas) nacen con la contraseña predeterminada: hasta cambiarla,
# la app no deja hacer otra cosa.
class AddMustChangePasswordToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :must_change_password, :boolean, default: false, null: false
  end
end
