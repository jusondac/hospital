# This file seeds the database with sample data for demonstration and testing

# Clear existing data
puts "Clearing existing data..."
Nurse.destroy_all if defined?(Nurse)
Patient.destroy_all if defined?(Patient)
Doctor.destroy_all if defined?(Doctor)
Room.destroy_all if defined?(Room)

# Create specialties
puts "Creating specialties..."
specialties = [ 'Surgery', 'Pediatrics', 'Cardiology', 'Neurology', 'Oncology' ]

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
15.times do |i|
  Nurse.create!(
    name: Faker::Name.name,
    specialization: [ 'Pediatrics', 'Cardiology', 'Neurology', 'Oncology' ].sample,
    gender: "female",
  ) if defined?(Nurse)
end

# Create rooms
puts "Creating rooms..."
room_types = [ 'Regular', 'ICU', 'Emergency', 'Surgery', 'Maternity' ]
30.times do |i|
  Room.create!(
    room_number: "#{rand(1..5)}#{rand(0..9)}#{rand(0..9)}",
    room_type: room_types.sample,
  ) if defined?(Room)
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
daily_counts = [ 28, 35, 42, 30, 45, 38, 50 ]  # Mon to Sun

# Create patients for the last 7 days with specific counts per day
7.times do |day_index|
  day_count = daily_counts[day_index]
  day_date = Date.today - (6 - day_index).days  # Starting from 6 days ago to today

  day_count.times do
    Patient.create!(
      name: Faker::Name.name,
      age: rand(1..100),
      gender: [ 'Male', 'Female' ].sample,
      condition: [ 'Critical', 'Stable', 'Recovering' ].sample,
      blood_type: [ 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' ].sample,
      admission_date: day_date,
      diagnosis: diagnoses.sample,
      room_id: Room.pluck(:id).sample
    ) if defined?(Patient)
  end
end

# Create additional patient data for historical records
30.times do
  admission_date = Date.today - rand(1..20).days
  Patient.create!(
    name: Faker::Name.name,
    age: rand(1..100),
    gender: [ 'Male', 'Female', 'Other' ].sample,
    blood_type: [ 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' ].sample,
    admission_date: admission_date,
    condition: [ 'Critical', 'Stable', 'Recovering' ].sample,
    diagnosis: diagnoses.sample,
    room_id: Room.pluck(:id).sample
  ) if defined?(Patient)
end

puts "Seed completed successfully!"
