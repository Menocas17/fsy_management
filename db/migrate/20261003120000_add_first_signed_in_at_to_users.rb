# Cuándo entró la cuenta por primera vez: «Todavía no entra» en la ficha se apoyaba en tener una sesión
# abierta, y al cerrar sesión la sesión se borra y la etiqueta volvía. Se llena con lo que ya se sabe.
class AddFirstSignedInAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :first_signed_in_at, :datetime

    execute <<~SQL
      UPDATE users SET first_signed_in_at = seen.first_at
      FROM (
        SELECT user_id, MIN(created_at) AS first_at FROM (
          SELECT user_id, created_at FROM login_attempts WHERE result = 0 AND user_id IS NOT NULL
          UNION ALL
          SELECT user_id, created_at FROM sessions
        ) AS signs
        GROUP BY user_id
      ) AS seen
      WHERE seen.user_id = users.id
    SQL
  end

  def down
    remove_column :users, :first_signed_in_at
  end
end
