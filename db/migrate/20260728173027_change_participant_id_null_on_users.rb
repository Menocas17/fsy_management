class ChangeParticipantIdNullOnUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :participant_id, true
  end
end
