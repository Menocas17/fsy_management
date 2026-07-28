# puts "🧹 Limpiando base de datos anterior..."
# Participant.destroy_all

# puts "🌱 Generando data de prueba..."

# nombres_hombres = [ "Carlos", "Pedro", "José", "Alejandro", "Mateo", "Daniel", "Gabriel", "Samuel", "David", "Lucas", "Juan", "Francisco", "Mauricio", "Eduardo", "Santiago" ]
# nombres_mujeres = [ "María", "Lucía", "Sofía", "Valeria", "Gabriela", "Camila", "Daniela", "Elena", "Victoria", "Sara", "Adriana", "Fernanda", "Paola", "Renata", "Jimena" ]
# apellidos = [ "Gómez", "Méndez", "Pérez", "Rodríguez", "López", "Martínez", "González", "Hernández", "García", "Flores", "Sánchez", "Ramírez", "Torres", "Díaz", "Cruz" ]

# stakes_disponibles = Participant.stakes.keys
# wards_disponibles = Participant.wards.keys
# tallas = [ "s", "m", "l", "xl" ]
# dietas = [ "Normal", "Vegetariana", "Sin Gluten" ]
# alergias_opciones = [ "Ninguna", "Ninguna", "Ninguna", "Polen", "Mariscos", "Maní" ]

# exitosos = 0

# 20.times do |i|
#   genre = [ "H", "M" ].sample
#   first_name = genre == "H" ? nombres_hombres.sample : nombres_mujeres.sample
#   last_name = apellidos.sample

#   data = {
#     first_name: first_name,
#     last_name: last_name,
#     age: rand(14..19),
#     rol: "logistica",
#     company: rand(1..10),
#     room: "#{[ 'A', 'B', 'C', 'D' ].sample}-#{rand(1..20)}",
#     stake: stakes_disponibles.sample,
#     ward: wards_disponibles.sample,
#     genre: genre,
#     identity_document: "001-#{rand(10..29)}0#{rand(1..9)}0#{rand(10..99)}#{[ 'A', 'B', 'X', 'Y' ].sample}",
#     shirt_number: tallas.sample,
#     phone_number: "8888-#{rand(1000..9999)}",
#     email_address: "#{first_name.downcase}.#{last_name.downcase}#{i}@example.com",
#     emergency_contact_name: "Familiar de #{first_name}",
#     emergency_contact_number: "7777-#{rand(1000..9999)}",
#     emergency_contact_relation: [ "Padre", "Madre", "Tutor" ].sample,
#     allergies: alergias_opciones.sample,
#     medicines: "Ninguna",
#     diet: dietas.sample
#   }

#   participant = Participant.new(data)

#   if participant.save
#     exitosos += 1
#   else
#     puts "❌ Error al guardar a #{participant.first_name}:"
#     participant.errors.map { |e| puts "   - #{e.attribute}: #{e.message}" }
#   end
# end

# puts "-------------------------------------------"
# puts "¡Proceso finalizado con éxito!"
# puts "🗑️ Registros anteriores eliminados."
# puts "✨ #{exitosos} registros agregados correctamente."
# puts "📊 Total actual en la base de datos: #{Participant.count}"
#




email = "josmenocal@outlook.com"
staff = Participant.where("contact_info ->> 'email_address' = ?", email).first

if staff.present?
  User.find_or_create_by!(email_address: email) do |user|
    user.password = "PasswordSeguro123"
    user.participant = staff
    puts "✅ Cuenta de usuario creada y vinculada al staff existente: #{staff.first_name} #{staff.last_name}"
  end
else
  puts "⚠️ Advertencia: No se encontró ningún participante con el correo #{email}. Asegúrate de registrarlo primero."
end
