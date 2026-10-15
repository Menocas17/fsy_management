# Cuándo confirmó la asignación quien la recibe: lo que mira quien la delegó en el seguimiento.
class AddConfirmedAtToAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :assignments, :confirmed_at, :datetime
  end
end
