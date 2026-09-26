class MigrateParticipantCompanyToForeignKey < ActiveRecord::Migration[8.1]
  def up
    add_reference :participants, :company, type: :uuid, foreign_key: { to_table: :companies }, null: true

    execute <<~SQL.squish
      INSERT INTO companies (name, created_at, updated_at)
      SELECT DISTINCT ('Compañía ' || company), now(), now()
      FROM participants
      WHERE company IS NOT NULL
    SQL

    execute <<~SQL.squish
      UPDATE participants p
      SET company_id = c.id
      FROM companies c
      WHERE p.company IS NOT NULL
        AND c.name = 'Compañía ' || p.company
    SQL

    remove_column :participants, :company
  end

  def down
    add_column :participants, :company, :integer

    execute <<~SQL.squish
      UPDATE participants p
      SET company = NULLIF(regexp_replace(c.name, '^Compañía ', ''), '')::integer
      FROM companies c
      WHERE p.company_id = c.id
    SQL

    remove_reference :participants, :company
  end
end
