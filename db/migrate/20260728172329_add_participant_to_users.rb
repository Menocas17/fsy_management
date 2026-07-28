class AddParticipantToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :participant, null: false, foreign_key: true, type: :uuid
  end
end
