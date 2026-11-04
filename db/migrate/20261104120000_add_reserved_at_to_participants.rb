# La reserva de consejeros: una ficha con reserved_at no existe para el resto de la app (default_scope de
# Participant), pero tampoco se borra. Solo el módulo Reserva (acceso total) la ve, la devuelve o la borra.
class AddReservedAtToParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :participants, :reserved_at, :datetime
    add_index :participants, :reserved_at, where: "reserved_at IS NOT NULL"
  end
end
