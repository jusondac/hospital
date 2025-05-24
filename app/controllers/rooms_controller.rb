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
    @pagy, @rooms = pagy(rooms.includes(:patients, :doctors, :nurses), limit: 7)
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
      # Assign doctors and nurses if selected
      if params[:room][:doctor_ids].present?
        @room.doctors = Doctor.where(id: params[:room][:doctor_ids])
      end
      if params[:room][:nurse_ids].present?
        @room.nurses = Nurse.where(id: params[:room][:nurse_ids])
      end
      
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
    if @room.update(room_params)
      # Update doctor and nurse associations
      if params[:room][:doctor_ids].present?
        @room.doctors = Doctor.where(id: params[:room][:doctor_ids])
      else
        @room.doctors.clear
      end
      
      if params[:room][:nurse_ids].present?
        @room.nurses = Nurse.where(id: params[:room][:nurse_ids])
      else
        @room.nurses.clear
      end
      
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
    params.require(:room).permit(:room_number, :room_type, :capacity, doctor_ids: [], nurse_ids: [])
  end
end
