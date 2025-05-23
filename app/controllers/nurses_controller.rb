class NursesController < ApplicationController
  before_action :set_nurse, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = Nurse.ransack(params[:q])
    @q.sorts = "created_at desc" if @q.sorts.empty?

    @pagy, @nurses = pagy(@q.result(distinct: true), items: 10)
  end

  def show
    # @nurse is set by the before_action
  end

  def new
    @nurse = Nurse.new
    @doctors = Doctor.all
  end

  def create
    @nurse = Nurse.new(nurse_params)

    # Ensure nurses are female
    if @nurse.gender != "female"
      @nurse.errors.add(:gender, "must be female")
      @doctors = Doctor.all
      render :new
      return
    end

    if @nurse.save
      redirect_to @nurse, notice: "Nurse was successfully created."
    else
      @doctors = Doctor.all
      render :new
    end
  end

  def edit
    # @nurse is set by the before_action
    @doctors = Doctor.all
  end

  def update
    # Ensure nurses are female
    if nurse_params[:gender] != "female"
      @nurse.errors.add(:gender, "must be female")
      @doctors = Doctor.all
      render :edit
      return
    end

    if @nurse.update(nurse_params)
      redirect_to @nurse, notice: "Nurse was successfully updated."
    else
      @doctors = Doctor.all
      render :edit
    end
  end

  def destroy
    @nurse.destroy
    redirect_to nurses_path, notice: "Nurse was successfully destroyed."
  end

  private

  def set_nurse
    @nurse = Nurse.find(params[:id])
  end

  def nurse_params
    params.require(:nurse).permit(:name, :gender, :specialization, :doctor_id)
  end
end
