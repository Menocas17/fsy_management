# La «Compañía» de la ficha de un consejero y su lugar en el personal de la compañía (memberships) se
# guardaban por separado y podían no coincidir. Desde ahora van juntas (Participant#sync_counselor_membership);
# esto empareja lo que ya hay: manda la asignación de personal, y a quien solo tenía la compañía en la ficha
# se le asigna si el lugar de su género está libre.
class SyncCounselorCompanies < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE participants p SET company_id = m.associable_id
      FROM memberships m
      WHERE m.participant_id = p.id AND m.associable_type = 'Company' AND m.role = 1 AND p.rol = 3
    SQL

    execute <<~SQL
      INSERT INTO memberships (id, associable_type, associable_id, participant_id, role, gender, created_at, updated_at)
      SELECT gen_random_uuid(), 'Company', p.company_id, p.id, 1, p.gender, now(), now()
      FROM participants p
      WHERE p.rol = 3 AND p.company_id IS NOT NULL AND p.gender IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM memberships m WHERE m.participant_id = p.id AND m.associable_type = 'Company' AND m.role = 1)
        AND NOT EXISTS (SELECT 1 FROM memberships m WHERE m.associable_type = 'Company' AND m.associable_id = p.company_id
                                                     AND m.role = 1 AND m.gender = p.gender)
    SQL
  end

  def down; end
end
