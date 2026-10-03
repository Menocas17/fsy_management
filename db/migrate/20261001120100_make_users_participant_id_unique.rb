# Un participante tiene a lo sumo una cuenta (Participant has_one :user).
class MakeUsersParticipantIdUnique < ActiveRecord::Migration[8.1]
  def up
    duplicated = select_values(<<~SQL)
      SELECT participant_id FROM users WHERE participant_id IS NOT NULL GROUP BY participant_id HAVING COUNT(*) > 1
    SQL
    if duplicated.any?
      raise "Hay participantes con más de una cuenta (#{duplicated.join(', ')}): deja una sola por participante antes de migrar."
    end

    remove_index :users, :participant_id
    add_index :users, :participant_id, unique: true
  end

  def down
    remove_index :users, :participant_id
    add_index :users, :participant_id
  end
end
