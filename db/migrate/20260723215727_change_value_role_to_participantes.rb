class ChangeValueRoleToParticipantes < ActiveRecord::Migration[8.1]
  def up
    change_column_default :participants, :rol, from: "participant", to: "participante"


    Participant.where(rol: "participant").update_all(rol: "participante")
  end

  def down
    change_column_default :participants, :rol, from: "participante", to: "participant"
  end
end
