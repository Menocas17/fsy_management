class AddDefaultStatusToParticipants < ActiveRecord::Migration[8.1]
  def up
    change_column_default :participants, :rol, from: nil, to: "participante"


    Participant.where(rol: nil).update_all(rol: "participante")
  end

  def down
    change_column_default :participants, :rol, from: "participante", to: nil
  end
end
