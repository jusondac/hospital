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
80.times do |i|  # Increased from 50 to 80 nurses
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
60.times do |i|  # Increased from 30 to 60 rooms
  # Set capacity based on room type with better distribution
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

# Create more historical data for better visualization (last 30 days)
30.times do |day_index|
  # Create a more realistic patient flow
  base_count = rand(8..15)  # Base number of admissions per day
  # Add some variation - weekends typically lower, some days higher
  day_of_week = (Date.today - (29 - day_index).days).wday
  weekend_modifier = (day_of_week == 0 || day_of_week == 6) ? 0.7 : 1.0
  random_modifier = rand(0.8..1.3)

  daily_count = (base_count * weekend_modifier * random_modifier).round
  admission_date = Date.today - (29 - day_index).days

  daily_count.times do
    # Find available rooms that can accommodate more patients
    available_rooms = RoomService.available_rooms
    room = available_rooms.sample

    patient = Patient.create!(
      name: Faker::Name.name,
      age: rand(1..100),
      gender: [ 'Male', 'Female' ].sample,
      condition: Patient.conditions.values.sample,
      blood_type: [ 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' ].sample,
      admission_date: admission_date,
      diagnosis: diagnoses.sample,
      room_id: room&.id
    ) if defined?(Patient)

    # Update room status after patient assignment
    if patient && room
      RoomService.update_room_status(room)
    end

    # Randomly discharge some older patients (20% chance for patients older than 7 days)
    if patient && admission_date < 7.days.ago && rand < 0.2
      # Discharge patient with a random discharge date between admission and today
      discharge_date = admission_date + rand(1..(Date.today - admission_date).to_i).days
      patient.update!(
        room: nil,
        condition: :discharged,
        discharge_date: discharge_date
      )
      RoomService.update_room_status(room) if room
    end
  end
end

# Create additional discharged patients from earlier periods for more realistic data
puts "Creating additional discharged patients..."
50.times do
  # Create patients from 1-6 months ago who have been discharged
  admission_date = Faker::Date.between(from: 6.months.ago, to: 1.month.ago)
  discharge_date = admission_date + rand(1..30).days

  Patient.create!(
    name: Faker::Name.name,
    age: rand(1..100),
    gender: [ 'Male', 'Female' ].sample,
    condition: :discharged,
    blood_type: [ 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' ].sample,
    admission_date: admission_date,
    discharge_date: discharge_date,
    diagnosis: diagnoses.sample,
    room_id: nil
  ) if defined?(Patient)
end

puts "Updating room statuses..."
Room.all.each do |room|
  RoomService.update_room_status(room)
end

puts "Seed completed successfully!"
