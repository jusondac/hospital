#!/usr/bin/env ruby
# Test script for active staff functionality

# Load Rails environment
require_relative 'config/environment'

puts "Testing Active Staff Functionality"
puts "=" * 40

# Test 1: Check if Room model has the new associations
puts "\n1. Testing Room model associations:"
room = Room.first
if room
  puts "✓ Room found: #{room.room_number}"
  
  # Test active associations
  begin
    active_doctors = room.active_doctors_assigned
    puts "✓ active_doctors_assigned method works: #{active_doctors.count} active doctors"
  rescue => e
    puts "✗ active_doctors_assigned method failed: #{e.message}"
  end
  
  begin
    active_nurses = room.active_nurses_assigned
    puts "✓ active_nurses_assigned method works: #{active_nurses.count} active nurses"
  rescue => e
    puts "✗ active_nurses_assigned method failed: #{e.message}"
  end
  
  # Test convenience methods
  begin
    room.respond_to?(:activate_doctor) ? puts("✓ activate_doctor method exists") : puts("✗ activate_doctor method missing")
    room.respond_to?(:deactivate_doctor) ? puts("✓ deactivate_doctor method exists") : puts("✗ deactivate_doctor method missing")
  rescue => e
    puts "✗ Error checking convenience methods: #{e.message}"
  end
else
  puts "✗ No rooms found in database"
end

# Test 2: Check RoomDoctor model
puts "\n2. Testing RoomDoctor model:"
room_doctor = RoomDoctor.first
if room_doctor
  puts "✓ RoomDoctor found"
  puts "  - Active: #{room_doctor.active}"
  puts "  - Has activated_at: #{room_doctor.respond_to?(:activated_at)}"
  puts "  - Has deactivated_at: #{room_doctor.respond_to?(:deactivated_at)}"
  
  # Test scopes
  begin
    active_count = RoomDoctor.active.count
    inactive_count = RoomDoctor.inactive.count
    puts "✓ Scopes work - Active: #{active_count}, Inactive: #{inactive_count}"
  rescue => e
    puts "✗ Scopes failed: #{e.message}"
  end
else
  puts "✗ No RoomDoctor records found"
end

# Test 3: Check RoomNurse model
puts "\n3. Testing RoomNurse model:"
room_nurse = RoomNurse.first
if room_nurse
  puts "✓ RoomNurse found"
  puts "  - Active: #{room_nurse.active}"
  puts "  - Has activated_at: #{room_nurse.respond_to?(:activated_at)}"
  puts "  - Has deactivated_at: #{room_nurse.respond_to?(:deactivated_at)}"
  
  # Test scopes
  begin
    active_count = RoomNurse.active.count
    inactive_count = RoomNurse.inactive.count
    puts "✓ Scopes work - Active: #{active_count}, Inactive: #{inactive_count}"
  rescue => e
    puts "✗ Scopes failed: #{e.message}"
  end
else
  puts "✗ No RoomNurse records found"
end

# Test 4: Test assign_staff method if we have data
puts "\n4. Testing assign_staff method:"
room = Room.first
doctor = Doctor.first
if room && doctor
  begin
    puts "Testing assign_staff with doctor #{doctor.id}"
    room.assign_staff(doctors: [doctor])
    puts "✓ assign_staff method works"
    
    # Check if the assignment is active
    assignment = room.room_doctors.find_by(doctor: doctor)
    if assignment && assignment.active?
      puts "✓ Doctor assignment is active"
    else
      puts "✗ Doctor assignment is not active"
    end
  rescue => e
    puts "✗ assign_staff method failed: #{e.message}"
  end
else
  puts "✗ No room or doctor available for testing"
end

puts "\n" + "=" * 40
puts "Test completed!"
