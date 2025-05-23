class DoctorsController < ApplicationController
  before_action :set_doctor, only: [ :show, :edit, :update, :destroy, :assign_nurse, :unassign_nurse ]

  def index
    @q = Doctor.ransack(params[:q])
    @q.sorts = "created_at desc" if @q.sorts.empty?

    @pagy, @doctors = pagy(@q.result(distinct: true), limit: 8)
  end

  def show
    # @doctor is set by the before_action
    @pagy, @available_nurses = pagy(Nurse.available, limit: 4)
  end

  def new
    @doctor = Doctor.new
  end

  def create
    @doctor = Doctor.new(doctor_params)

    if @doctor.save
      redirect_to @doctor, notice: "Doctor was successfully created."
    else
      render :new
    end
  end

  def edit
    # @doctor is set by the before_action
  end

  def update
    if @doctor.update(doctor_params)
      redirect_to @doctor, notice: "Doctor was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @doctor.destroy
    redirect_to doctors_path, notice: "Doctor was successfully destroyed."
  end

  def assign_nurse
    @nurse = Nurse.find(params[:nurse_id])

    if @nurse.update(doctor: @doctor)
      redirect_to @doctor, notice: "Nurse #{@nurse.name} was successfully assigned to this doctor."
    else
      redirect_to @doctor, alert: "Failed to assign nurse. Please try again."
    end
  end

  def unassign_nurse
    @nurse = Nurse.find(params[:nurse_id])

    if @nurse.update(doctor: nil)
      redirect_to @doctor, notice: "Nurse #{@nurse.name} was successfully unassigned from this doctor."
    else
      redirect_to @doctor, alert: "Failed to unassign nurse. Please try again."
    end
  end

  private

  def set_doctor
    @doctor = Doctor.find(params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(:name, :gender, :specialization)
  end
end
