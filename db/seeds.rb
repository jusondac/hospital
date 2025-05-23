# This file seeds the database with sample data for demonstration and testing

# Clear existing data
puts "Clearing existing data..."
Room.destroy_all
Patient.destroy_all
Nurse.destroy_all
Doctor.destroy_all

# Create Doctors
puts "Creating doctors..."
doctors = [
  { name: "Dr. James Wilson", gender: "male", specialization: "Oncology" },
  { name: "Dr. Meredith Grey", gender: "female", specialization: "General Surgery" },
  { name: "Dr. Gregory House", gender: "male", specialization: "Diagnostics" },
  { name: "Dr. Miranda Bailey", gender: "female", specialization: "Pediatrics" },
  { name: "Dr. Derek Shepherd", gender: "male", specialization: "Neurosurgery" }
]

created_doctors = doctors.map do |doctor_attrs|
  Doctor.create!(doctor_attrs)
end

# Create Nurses (all female)
puts "Creating nurses..."
nurses = [
  { name: "Jane Smith", gender: "female", specialization: "Intensive Care" },
  { name: "Emily Johnson", gender: "female", specialization: "Emergency" },
  { name: "Sandra Lee", gender: "female", specialization: "Pediatrics" },
  { name: "Olivia Martinez", gender: "female", specialization: "Oncology" },
  { name: "Rachel Williams", gender: "female", specialization: "Surgery" },
  { name: "Lisa Chen", gender: "female", specialization: "Cardiology" },
  { name: "Grace Kim", gender: "female", specialization: "Neurology" },
  { name: "Sophie Wilson", gender: "female", specialization: "Geriatrics" },
  { name: "Amara Jackson", gender: "female", specialization: "Obstetrics" },
  { name: "Zoe Thomas", gender: "female", specialization: "Psychiatric" }
]

created_nurses = nurses.map do |nurse_attrs|
  Nurse.create!(nurse_attrs)
end

# Assign nurses to doctors
puts "Assigning nurses to doctors..."
created_doctors.each_with_index do |doctor, index|
  # Assign 2 nurses to each doctor, cycling through the available nurses
  2.times do |i|
    nurse_index = (index * 2 + i) % created_nurses.length
    doctor.assign_nurse(created_nurses[nurse_index])
  end
end

# Create Rooms
puts "Creating rooms..."
room_types = [ "Standard", "Intensive Care", "Operating", "Emergency", "Maternity", "Pediatric", "Psychiatric" ]

20.times do |i|
  room_number = "#{('A'..'E').to_a[i / 4]}#{(i % 4) + 101}"
  room_type = room_types[i % room_types.length]

  # Assign a doctor and nurse to each room
  doctor = created_doctors[i % created_doctors.length]
  nurse = doctor.nurses.sample

  Room.create!(
    room_number: room_number,
    room_type: room_type,
    doctor: doctor,
    nurse: nurse
  )
end

# Create Patients
puts "Creating patients..."
conditions = [
  "Pneumonia", "Fractured Arm", "Appendicitis", "Heart Disease",
  "Diabetes", "Hypertension", "Cancer", "Allergic Reaction",
  "Burns", "Concussion", "Influenza", "Kidney Stones",
  "Arthritis", "Asthma", "Stable", "Critical", "Recovering"
]

15.times do |i|
  gender = [ "male", "female" ].sample
  first_name = if gender == "male"
                [ "James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph", "Thomas", "Charles" ].sample
  else
                [ "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica", "Sarah", "Karen" ].sample
  end

  last_name = [ "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez" ].sample

  patient = Patient.create!(
    name: "#{first_name} #{last_name}",
    gender: gender,
    age: rand(1..90),
    condition: conditions.sample
  )

  # Assign some patients to rooms (leave some unassigned)
  if i < 10  # Only assign 10 out of 15 patients to rooms
    available_rooms = Room.all.select(&:available?)
    if available_rooms.any?
      room = available_rooms.sample
      patient.update(room: room)
    end
  end
end

puts "Seeding completed successfully!"
puts "Created #{Doctor.count} doctors"
puts "Created #{Nurse.count} nurses"
puts "Created #{Room.count} rooms"
puts "Created #{Patient.count} patients"
puts "#{Room.all.reject(&:available?).count} rooms are occupied"
