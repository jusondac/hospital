class PatientsController < ApplicationController
  before_action :set_patient, only: [ :show, :edit, :update, :destroy, :discharge ]

  def index
    @q = Patient.ransack(params[:q])
    @q.sorts = "created_at desc" if @q.sorts.empty?

    # Use the Ransack search results for pagination
    @pagy, @patients = pagy(@q.result(distinct: true), limit: 8)
  end

  def show
    # @patient is set by the before_action
  end

  def new
    @patient = Patient.new
    @rooms = Room.where(patient: nil, doctor: nil)
  end

  def create
    @patient = Patient.new(patient_params)

    if @patient.save
      redirect_to @patient, notice: "Patient was successfully created."
    else
      @rooms = Room.where(patient: nil, doctor: nil)
      render :new
    end
  end

  def edit
    # @patient is set by the before_action
    @rooms = Room.where(patient: nil, doctor: nil)
    # Include the current room even if it's occupied by this patient
    @rooms = @rooms.or(Room.where(id: @patient.room_id)) if @patient.room_id.present?
  end

  def update
    if @patient.update(patient_params)
      redirect_to @patient, notice: "Patient was successfully updated."
    else
      @rooms = Room.where(patient: nil, doctor: nil)
      # Include the current room even if it's occupied by this patient
      @rooms = @rooms.or(Room.where(id: @patient.room_id)) if @patient.room_id.present?
      render :edit
    end
  end

  def destroy
    @patient.destroy
    redirect_to patients_path, notice: "Patient was successfully destroyed."
  end

  def discharge
    if @patient.discharge!
      redirect_to @patient, notice: "#{@patient.name} has been successfully discharged and the room is now available."
    else
      redirect_to @patient, alert: "Failed to discharge patient. Patient may not be assigned to a room."
    end
  end

  private

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def patient_params
    params.require(:patient).permit(:name, :gender, :age, :condition, :room_id)
  end
end
