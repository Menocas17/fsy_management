# Enfermería: cada visita de un joven (avisada por su consejero, confirmada por enfermería, dada de alta) y
# las notas de su ficha clínica, que solo se agregan. Quien avisó, ingresó o escribió queda también por nombre:
# si se borra su ficha, la visita no se pierde.
class CreateInfirmaryVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :infirmary_visits, id: :uuid do |t|
      t.references :participant, type: :uuid, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :reason, null: false
      t.text :reason_detail
      t.datetime :announced_at
      t.references :announced_by, type: :uuid, foreign_key: { to_table: :participants, on_delete: :nullify }
      t.string :announced_by_name
      t.datetime :admitted_at
      t.references :admitted_by, type: :uuid, foreign_key: { to_table: :participants, on_delete: :nullify }
      t.string :admitted_by_name
      t.datetime :discharged_at
      t.references :discharged_by, type: :uuid, foreign_key: { to_table: :participants, on_delete: :nullify }
      t.string :discharged_by_name
      t.integer :disposition
      t.text :discharge_notes
      t.timestamps
    end
    # Una sola visita abierta (en camino o adentro) por joven.
    add_index :infirmary_visits, :participant_id, unique: true, where: "discharged_at IS NULL", name: "index_infirmary_visits_one_open_per_participant"
    add_index :infirmary_visits, :discharged_at

    create_table :infirmary_notes, id: :uuid do |t|
      t.references :infirmary_visit, type: :uuid, null: false, foreign_key: true
      t.references :author, type: :uuid, foreign_key: { to_table: :participants, on_delete: :nullify }
      t.string :author_name, null: false
      t.integer :kind, null: false, default: 0
      t.text :body
      t.jsonb :vitals, null: false, default: {}
      t.timestamps
    end
  end
end
