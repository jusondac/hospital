module Api
  class ChartsController < ApplicationController


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

    def doctor_specialties
      # Get count of doctors by specialization
      specialties = Doctor.group(:specialization).count

      render json: {
        labels: specialties.keys,
        data: specialties.values
      }
    end
  end
end
