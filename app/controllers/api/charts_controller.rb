module Api
  class ChartsController < ApplicationController
    def dashboard_stats
      render json: {
        total_patients: Patient.count,
        available_rooms: Room.where(patient_id: nil).count,
        active_doctors: Doctor.count,
        on_duty_nurses: Nurse.count,
        occupancy_rate: calculate_occupancy_rate
      }
    end

    def patient_admissions
      # Get patient admissions for the last 7 days
      data = []
      labels = []

      7.times do |i|
        date = Date.today - (6 - i).days
        count = Patient.where(admission_date: date).count

        labels << date.strftime("%a")
        data << count
      end

      render json: {
        labels: labels,
        data: data
      }
    end

    def patient_trend
      # Get patient admissions and discharges for the last 30 days
      admissions = []
      discharges = []
      labels = []

      30.times do |i|
        date = Date.today - (29 - i).days
        admission_count = Patient.where(admission_date: date).count
        discharge_count = Patient.where(discharge_date: date).count

        labels << date.strftime("%m/%d")
        admissions << admission_count
        discharges << discharge_count
      end

      render json: {
        labels: labels,
        admissions: admissions,
        discharges: discharges
      }
    end

    def room_occupancy
      # Get room occupancy for the last 7 days
      occupied = []
      capacity = []
      labels = []

      7.times do |i|
        date = Date.today - (6 - i).days
        total_rooms = Room.count
        occupied_rooms = Room.joins(:patient).where(patients: { admission_date: ..date }).where("patients.discharge_date IS NULL OR patients.discharge_date > ?", date).count

        labels << date.strftime("%a")
        occupied << occupied_rooms
        capacity << total_rooms
      end

      render json: {
        labels: labels,
        occupied: occupied,
        capacity: capacity
      }
    end

    def patient_conditions
      # Get patient condition distribution
      conditions = Patient.where(discharge_date: nil).group(:condition).count

      render json: {
        labels: conditions.keys.map(&:humanize),
        data: conditions.values
      }
    end

    def staff_workload
      # Get patients per staff member by specialty
      specialties = Doctor.distinct.pluck(:specialization)
      doctor_workload = []
      nurse_workload = []

      specialties.each do |specialty|
        doctors_count = Doctor.where(specialization: specialty).count
        nurses_count = Nurse.where(specialization: specialty).count
        patients_count = Patient.joins(room: :doctor).where(doctors: { specialization: specialty }, discharge_date: nil).count

        doctor_workload << doctors_count > 0 ? (patients_count.to_f / doctors_count).round(1) : 0
        nurse_workload << nurses_count > 0 ? (patients_count.to_f / nurses_count).round(1) : 0
      end

      render json: {
        specialties: specialties,
        doctors: doctor_workload,
        nurses: nurse_workload
      }
    end

    def monthly_trends
      # Get monthly trends for the last 6 months
      admissions = []
      discharges = []
      transfers = []
      months = []

      6.times do |i|
        month_start = (Date.today - (5 - i).months).beginning_of_month
        month_end = month_start.end_of_month

        admission_count = Patient.where(admission_date: month_start..month_end).count
        discharge_count = Patient.where(discharge_date: month_start..month_end).count
        # Transfer count - approximated as room changes
        transfer_count = Patient.joins(:room).where(updated_at: month_start..month_end).count / 10 # rough estimate

        months << month_start.strftime("%b")
        admissions << admission_count
        discharges << discharge_count
        transfers << transfer_count
      end

      render json: {
        months: months,
        admissions: admissions,
        discharges: discharges,
        transfers: transfers
      }
    end

    def doctor_specialties
      # Get count of doctors by specialization
      specialties = Doctor.group(:specialization).count

      render json: {
        labels: specialties.keys,
        data: specialties.values
      }
    end

    private

    def calculate_occupancy_rate
      total_rooms = Room.count
      return 0 if total_rooms == 0

      occupied_rooms = Room.where.not(patient_id: nil).count
      ((occupied_rooms.to_f / total_rooms) * 100).round(1)
    end
  end
end
