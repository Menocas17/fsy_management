class ChangeResponToTypeInParticipants < ActiveRecord::Migration[8.1]
  def change
    change_column :participants, :respond_to, 'jsonb USING respond_to::jsonb'
  end
end
