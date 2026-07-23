class AddContactInfoToParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :participants, :contact_info, :jsonb
  end
end
