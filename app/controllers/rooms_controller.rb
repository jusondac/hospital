class RoomsController < ApplicationController
  before_action :set_room, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = Room.ransack(params[:q])
    @pagy, @rooms = pagy(@q.result(distinct: true), limit: 8)
  end

  def show
    # @room is set by the before_action
  end

  def new
    @room = Room.new
    @doctors = Doctor.all
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
    @doctors = Doctor.all
    @nurses = Nurse.where(gender: "female")
  end

  def update
    if @room.update(room_params)
      redirect_to @room, notice: "Room was successfully updated."
    else
      @doctors = Doctor.all
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
    params.require(:room).permit(:room_number, :room_type, :doctor_id, :nurse_id)
  end
end
