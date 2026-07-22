class CreateParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :participants, id: :uuid do |t|
      t.integer :rol
      t.string :first_name
      t.string :last_name
      t.integer :age
      t.integer :stake
      t.integer :ward
      t.date :date_of_inscription
      t.integer :shirt_number
      t.string :room
      t.integer :company
      t.string :respond_to
      t.jsonb :medical_info
      t.text :additional_instructions
      t.integer :identity_document
      t.integer :genre

      t.timestamps
    end
  end
end
