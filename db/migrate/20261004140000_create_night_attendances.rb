class CreateNightAttendances < ActiveRecord::Migration[8.1]
  def change
    # La asistencia nocturna: cada noche, el consejero de cada género confirma en su compañía quién está en
    # el cuarto. Una lista por compañía, noche y género; una marca por joven.
    create_table :night_attendances, id: :uuid do |t|
      t.references :company, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.date :night_on, null: false
      t.integer :gender, null: false
      t.references :taken_by, foreign_key: { to_table: :participants, on_delete: :nullify }, type: :uuid
      t.string :taken_by_name, null: false
      t.datetime :confirmed_at, null: false
      t.timestamps
    end
    add_index :night_attendances, %i[company_id night_on gender], unique: true
    add_index :night_attendances, :night_on

    create_table :night_attendance_marks, id: :uuid do |t|
      t.references :night_attendance, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :participant, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.integer :status, null: false
      t.integer :absence_reason
      t.string :absence_detail
      t.timestamps
    end
    add_index :night_attendance_marks, %i[night_attendance_id participant_id], unique: true
  end
end
