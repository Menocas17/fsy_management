# Lo que trae el archivo oficial de la Iglesia y la app no guardaba: el nombre que prefiere, la fecha de
# nacimiento (de la que sale la edad) y, para el staff, una estaca y un barrio fuera de los que participan.
# Alergias y medicinas pasan a ser una sola «Información médica», como la escribe la familia en la inscripción.
class AddChurchFieldsToParticipants < ActiveRecord::Migration[8.1]
  NONE = [ "ninguna", "ninguno", "ninguna.", "sin restricciones", "sin restriccion", "sin alergias",
           "sin dieta", "n/a", "na", "no", "-", "--" ].freeze

  def up
    add_column :participants, :preferred_name, :string
    add_column :participants, :birth_date, :date
    add_column :participants, :other_stake, :string
    add_column :participants, :other_ward, :string

    select_rows("SELECT id, medical_info FROM participants WHERE medical_info ?| array['allergies', 'medicines']").each do |id, raw|
      info = raw.is_a?(String) ? JSON.parse(raw) : raw.to_h
      parts = { "Alergias" => info.delete("allergies"), "Medicinas" => info.delete("medicines") }
                .select { |_, value| value.to_s.strip.present? && !NONE.include?(value.to_s.strip.downcase) }
      text = parts.map { |label, value| "#{label}: #{value.to_s.strip}" }.join("\n").presence
      info["medical_information"] = text if text && info["medical_information"].blank?
      execute "UPDATE participants SET medical_info = #{connection.quote(info.to_json)}::jsonb WHERE id = #{connection.quote(id)}"
    end
  end

  def down
    remove_column :participants, :preferred_name
    remove_column :participants, :birth_date
    remove_column :participants, :other_stake
    remove_column :participants, :other_ward
  end
end
