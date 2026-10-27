class AddRegistrationStatusToParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :participants, :registration_status, :string
  end
end
