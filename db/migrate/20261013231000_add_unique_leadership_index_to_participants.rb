# Un director y una directora, un coordinador y una coordinadora, un director y una directora de logística
# (Participant::LEADERSHIP_ROLES): la validación ya lo cuidaba, ahora también la base, para que dos altas a la
# vez no dejen un tercero con acceso total. Si la base ya tiene un duplicado, no se crea el índice (y lo avisa):
# el arranque no se cae por eso, y el duplicado se corrige a mano.
class AddUniqueLeadershipIndexToParticipants < ActiveRecord::Migration[8.1]
  ROLES = "rol IN (0, 1, 7)".freeze # director, coordinador, director_logistica

  def up
    duplicates = select_value(<<~SQL).to_i
      SELECT count(*) FROM (
        SELECT 1 FROM participants WHERE #{ROLES} AND gender IS NOT NULL GROUP BY rol, gender HAVING count(*) > 1
      ) dupes
    SQL
    if duplicates.positive?
      say "Hay #{duplicates} rol(es) de dirección repetidos por género: corrígelos y vuelve a correr esta migración."
      return
    end

    add_index :participants, %i[rol gender], unique: true, where: "#{ROLES} AND gender IS NOT NULL",
                                              name: "index_participants_one_leader_per_gender"
  end

  def down
    remove_index :participants, name: "index_participants_one_leader_per_gender", if_exists: true
  end
end
