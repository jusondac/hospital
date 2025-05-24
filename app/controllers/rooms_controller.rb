class RoomsController < ApplicationController
  before_action :set_room, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = Room.ransack(params[:q])
    rooms = @q.result(distinct: true)

    # Apply room type filter if present
    if params[:room_type].present?
      rooms = rooms.where(room_type: params[:room_type])
    end

    # Apply status filter using the room_status column
    if params[:status].present?
      rooms = rooms.where(room_status: params[:status])
    end

    # Use regular pagy for all database queries
    @pagy, @rooms = pagy(rooms.includes(:patients, :doctor, :nurse), limit: 8)
  end

  def show
    # @room is set by the before_action
  end

  def new
    @room = Room.new
    @q = Doctor.ransack(params[:q])
    @doctors = @q.result(distinct: true)
    @nurses = Nurse.where(gender: "female")
  end

  def create
    @room = Room.new(room_params)

    if @room.save
      redirect_to @room, notice: "Room was successfully created."
    else
      @doctors = Doctor.all
      @nurses = Nurse.where(gender: "female")
      render :new
    end
  end

  def edit
    # @room is set by the before_action
    @q = Doctor.ransack(params[:q])
    @doctors = @q.result.includes(:nurses)
    @nurses = Nurse.where(gender: "female")
  end

  def update
    # Get the updated room parameters
    update_params = room_params

    # If a doctor is being assigned and they have nurses, auto-assign the first nurse
    if update_params[:doctor_id].present?
      doctor = Doctor.find(update_params[:doctor_id])
      if doctor.nurses.any? && update_params[:nurse_id].blank?
        # Only auto-assign if no nurse was manually selected
        update_params[:nurse_id] = doctor.nurses.first.id
      end
    # If doctor is being removed, also remove the nurse
    elsif update_params[:doctor_id].blank?
      update_params[:nurse_id] = nil
    end

    if @room.update(update_params)
      redirect_to @room, notice: "Room was successfully updated."
    else
      @doctors = Doctor.includes(:nurses).all
      @nurses = Nurse.where(gender: "female")
      render :edit
    end
  end

  def destroy
    @room.destroy
    redirect_to rooms_path, notice: "Room was successfully destroyed."
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:room_number, :room_type, :doctor_id, :nurse_id, :capacity)
  end
end
