class AddCodeToParticipants < ActiveRecord::Migration[8.1]
  # Código corto del gafete (P-0421) para registrar a mano cuando el QR no se lee: el id es un UUID
  # imposible de escribir. A los que ya existen se les numera por orden de creación.
  def up
    add_column :participants, :code, :string
    add_index :participants, :code, unique: true

    execute <<~SQL.squish
      UPDATE participants SET code = numbered.code
      FROM (
        SELECT id, 'P-' || lpad(row_number() OVER (ORDER BY created_at, id)::text, 4, '0') AS code
        FROM participants
      ) AS numbered
      WHERE participants.id = numbered.id
    SQL
  end

  def down
    remove_index :participants, :code
    remove_column :participants, :code
  end
end
