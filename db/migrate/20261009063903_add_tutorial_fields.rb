# El tutorial: cuándo lo terminó (o saltó) cada cuenta, y los jóvenes de práctica con los que se practica
# llevar a enfermería y pasar el Conteo. Los de práctica no aparecen en ninguna parte fuera del tutorial
# (Participant tiene default_scope sin ellos).
class AddTutorialFields < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :tutorial_completed_at, :datetime
    add_column :participants, :practice, :boolean, default: false, null: false
    add_index :participants, :practice, where: "practice"
  end
end
