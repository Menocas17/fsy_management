puts "Agregando nuevos participantes de prueba..."

nuevos_participantes_data = [
  {
    first_name: "Pedro",
    last_name: "Gómez",
    age: 16,
    rol: "joven",
    company: 3,
    room: "C-15",
    stake: "bello_horizonte",
    ward: "ducuali",
    genre: "H",
    identity_document: "001-050402-1002X",
    shirt_number: "l",
    phone_number: "8888-1111",
    email_address: "pedro.gomez@example.com",
    emergency_contact_name: "José Gómez",
    emergency_contact_number: "7777-2222",
    emergency_contact_relation: "Padre",
    allergies: "Ninguna",
    medicines: "Ninguna",
    diet: "Normal"
  },
  {
    first_name: "Lucía",
    last_name: "Méndez",
    age: 15,
    rol: "joven",
    company: 4,
    room: "D-02",
    stake: "las_americas",
    ward: "la_maximo_jerez",
    genre: "M",
    identity_document: "001-101004-2003Y",
    shirt_number: "m",
    phone_number: "8888-3333",
    email_address: "lucia.mendez@example.com",
    emergency_contact_name: "Carmen Méndez",
    emergency_contact_number: "7777-4444",
    emergency_contact_relation: "Madre",
    allergies: "Mariscos",
    medicines: "Ninguna",
    diet: "Normal"
  }
]

exitosos = 0

nuevos_participantes_data.each do |data|
  participant = Participant.new(data)

  if participant.save
    puts "✅ Creado con éxito: #{participant.first_name} #{participant.last_name}"
    exitosos += 1
  else
    puts "❌ Error al guardar a #{participant.first_name}:"
    participant.errors.map { |e| puts "   - #{e.attribute}: #{e.message}" }
  end
end

puts "-------------------------------------------"
puts "¡#{exitosos} participantes nuevos agregados!"
puts "Total actual en la base de datos: #{Participant.count}"
