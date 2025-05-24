# This file seeds the database with sample data for demonstration and testing

# Clear existing data
puts "Clearing existing data..."
Patient.destroy_all
Room.destroy_all
Nurse.destroy_all
Doctor.destroy_all

# Create specialties
puts "Creating specialties..."
# specialties = [ 'Surgery', 'Pediatrics', 'Cardiology', 'Neurology', 'Oncology' ]

# Create doctors with specialties
puts "Creating doctors..."
# Create a specific distribution for the chart visualization
specialty_counts = {
  'Surgery' => 12,
  'Pediatrics' => 8,
  'Cardiology' => 10,
  'Neurology' => 7,
  'Oncology' => 5
}

specialty_counts.each do |specialty, count|
  count.times do
    Doctor.create!(
      name: Faker::Name.name,
      specialization: specialty,
      gender: [ 'Male', 'Female' ].sample
    ) if defined?(Doctor)
  end
end

# Create nurses
puts "Creating nurses..."
50.times do |i|
  Nurse.create!(
    name: Faker::Name.name,
    specialization: [ 'Pediatrics', 'Cardiology', 'Neurology', 'Oncology' ].sample,
    gender: "female",
  ) if defined?(Nurse)
end

puts "Assigning nurses to doctors..."
Doctor.all.each do |doctor|
  # Assign a nurse to each doctor
  nurse = Nurse.available.sample
  nurse.update(doctor: doctor) if nurse
end

# Create rooms
puts "Creating rooms..."
30.times do |i|
  # Set capacity based on room type
  room_type = Room.room_types.keys.sample
  capacity = case room_type
  when 'general_ward' then [ 4, 6, 8 ].sample
  when 'private_room' then 1
  when 'icu' then [ 2, 4 ].sample
  when 'operating_room' then 1
  when 'emergency_room' then [ 6, 8, 10 ].sample
  else 2
  end

  room = Room.create!(
    room_number: "#{room_type[0].upcase}#{i.to_s.rjust(3, '0')}",
    room_type: room_type,
    capacity: capacity,
  ) if defined?(Room)

  # Assign multiple doctors and nurses to rooms randomly
  if room
    # Assign 1-3 doctors randomly
    doctor_count = rand(1..3)
    available_doctors = Doctor.all.sample(doctor_count)
    room.doctors = available_doctors

    # Assign 1-2 nurses randomly
    nurse_count = rand(1..2)
    available_nurses = Nurse.all.sample(nurse_count)
    room.nurses = available_nurses

    # Update room status using the service
    RoomService.update_room_status(room)
  end
end

# Create array of diagnoses (diseases)
diagnoses = [
  'Pneumonia',
  'Diabetes Mellitus',
  'Hypertension',
  'Asthma',
  'Chronic Kidney Disease',
  'Coronary Artery Disease',
  'Stroke',
  'Tuberculosis',
  'Malaria',
  'Dengue Fever',
  'COVID-19',
  'Cancer',
  'Appendicitis',
  'Hepatitis B',
  'Hepatitis C',
  'Migraine',
  'Epilepsy',
  'Arthritis',
  'Osteoporosis',
  'Anemia',
  'Leukemia',
  'Bronchitis',
  'COPD',
  'Gastritis',
  'Peptic Ulcer',
  'Gallstones',
  'Pancreatitis',
  'HIV/AIDS',
  'Meningitis',
  'Chickenpox',
  'Measles',
  'Rheumatic Fever',
  'Thyroid Disorder',
  'Obesity',
  'Depression',
  'Schizophrenia',
  'Bipolar Disorder',
  'Parkinson\'s Disease',
  'Alzheimer\'s Disease',
  'Glaucoma',
  'Cataract'
]

# Create patients with admission dates - updated for better chart visualization
puts "Creating patients..."
# Create a specific distribution for the weekly chart
daily_counts = [ 15, 18, 22, 16, 25, 20, 28 ]  # Mon to Sun - reduced counts

# Create patients for the last 7 days with specific counts per day
7.times do |day_index|
  day_count = daily_counts[day_index]
  day_date = Date.today - (6 - day_index).days  # Starting from 6 days ago to today

  day_count.times do
    # Find available rooms that can accommodate more patients
    available_rooms = RoomService.available_rooms
    room = available_rooms.sample

    patient = Patient.create!(
      name: Faker::Name.name,
      age: rand(1..100),
      gender: [ 'Male', 'Female' ].sample,
      condition: Patient.conditions.values.sample,
      blood_type: [ 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' ].sample,
      admission_date: day_date,
      diagnosis: diagnoses.sample,
      room_id: room&.id
    ) if defined?(Patient)

    # Update room status after patient assignment
    if patient && room
      RoomService.update_room_status(room)
    end

    # Set room to nil if patient is discharged
    if patient&.discharged?
      patient.update(room: nil)
    end
  end
end

# Create additional patient data for historical records
# 30.times do
#   admission_date = Date.today - rand(1..20).days
#   room = Room.available.sample&.id

#   patient = Patient.create!(
#     name: Faker::Name.name,
#     age: rand(1..100),
#     gender: [ 'Male', 'Female', 'Other' ].sample,
#     blood_type: [ 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' ].sample,
#     admission_date: admission_date,
#     condition: Patient.conditions.values.sample,
#     diagnosis: diagnoses.sample,
#     room_id: room
#   ) if defined?(Patient)
#   patient.update(room: nil) if patient.discharged?
# end

puts "Updating room statuses..."
Room.all.each do |room|
  RoomService.update_room_status(room)
end

puts "Seed completed successfully!"
