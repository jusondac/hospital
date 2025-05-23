class Api::NursesController < ApplicationController
  def available
    # Get nurses that are not assigned to any doctor or are available for room assignment
    available_nurses = Nurse.where(gender: "female")

    render json: {
      nurses: available_nurses.map do |nurse|
        {
          id: nurse.id,
          name: nurse.name,
          specialization: nurse.specialization,
          gender: nurse.gender
        }
      end
    }
  rescue => e
    render json: { error: "Failed to fetch nurses" }, status: :internal_server_error
  end
end
