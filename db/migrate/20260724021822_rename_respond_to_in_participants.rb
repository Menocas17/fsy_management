class RenameRespondToInParticipants < ActiveRecord::Migration[8.1]
  def change
    rename_column :participants, :respond_to, :person_in_charge
  end
end
