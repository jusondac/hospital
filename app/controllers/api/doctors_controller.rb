class Api::DoctorsController < ApplicationController
  def nurses
    doctor = Doctor.find(params[:id])
    nurses = doctor.nurses

    render json: {
      nurses: nurses.map do |nurse|
        {
          id: nurse.id,
          name: nurse.name,
          specialization: nurse.specialization,
          gender: nurse.gender
        }w
      end
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Doctor not found" }, status: :not_found
  end
end
