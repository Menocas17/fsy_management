# Antes la cuenta del sistema era «un User sin participante»: al borrar a un participante su cuenta quedaba
# sin participante y pasaba a ser superadmin. Ahora es una marca explícita.
class AddSuperadminToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :superadmin, :boolean, default: false, null: false
    # Las cuentas que hoy no tienen participante: la del sistema y, si se borró alguna ficha con cuenta, esas
    # también (el error que esto corrige). Se listan para revisarlas a mano después del deploy.
    marked = select_values("UPDATE users SET superadmin = TRUE WHERE participant_id IS NULL RETURNING email_address")
    say "Marcadas como superadmin (revisa que solo esté la cuenta del sistema): #{marked.join(', ').presence || 'ninguna'}"
  end

  def down
    remove_column :users, :superadmin
  end
end
