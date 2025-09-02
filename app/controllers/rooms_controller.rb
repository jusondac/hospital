class RoomsController < ApplicationController
  before_action :set_room, only: [ :show, :edit, :update, :destroy ]

  def index
    # Ultra-fast implementation using bulk operations
    filters = {
      room_type: params[:room_type],
      status: params[:status]
    }

    # Get total count for pagination (fast single query)
    total_count = Room.fast_count(filters: filters)

    # Calculate pagination parameters
    limit = 7
    page = params[:page]&.to_i || 1
    offset = (page - 1) * limit

    # Load rooms with all data in a single optimized query
    @rooms = Room.load_with_counts(
      limit: limit,
      offset: offset,
      filters: filters
    )

    # Create pagination object manually for better performance
    @pagy = Pagy.new(count: total_count, page: page, limit: limit)

    # Add search functionality if needed
    if params[:q].present?
      search_term = params[:q].to_s.downcase
      @rooms = @rooms.select { |room|
        room.room_number.to_s.downcase.include?(search_term) ||
        room.room_type.to_s.downcase.include?(search_term)
      }
    end
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
      # Assign doctors and nurses using the assign_staff method that handles active status
      doctors = params[:room][:doctor_ids].present? ? Doctor.where(id: params[:room][:doctor_ids]) : []
      nurses = params[:room][:nurse_ids].present? ? Nurse.where(id: params[:room][:nurse_ids]) : []
      
      if doctors.any? || nurses.any?
        @room.assign_staff(doctors, nurses)
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
      # Update doctor and nurse associations using assign_staff method that handles active status
      doctors = params[:room][:doctor_ids].present? ? Doctor.where(id: params[:room][:doctor_ids]) : []
      nurses = params[:room][:nurse_ids].present? ? Nurse.where(id: params[:room][:nurse_ids]) : []
      
      # Always call assign_staff to update active status (it will deactivate current staff if empty arrays)
      @room.assign_staff(doctors, nurses)

      redirect_to @room, notice: "Room was successfully updated."
    else
      @doctors = Doctor.includes(:nurses).all
      @nurses = Nurse.all
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

  # Preload associations for better performance when cached counts aren't available
  def preload_room_associations
    return unless @rooms.respond_to?(:each)

    @rooms.each do |room|
      # Skip if we already have cached counts from bulk load
      next if room.instance_variable_defined?(:@patients_count)

      # Preload associations if we don't have cached counts
      room.association(:patients).load_target
      room.association(:doctors).load_target
      room.association(:nurses).load_target
    end
  end

  # Fast bulk preloading method
  def bulk_preload_associations
    return unless @rooms.respond_to?(:each)

    room_ids = @rooms.map(&:id)

    # Bulk load all associations in parallel queries, including active staff only
    patients_by_room = Patient.where(room_id: room_ids).group_by(&:room_id)
    active_doctors_by_room = RoomDoctor.includes(:doctor).where(room_id: room_ids, active: true).group_by(&:room_id)
    active_nurses_by_room = RoomNurse.includes(:nurse).where(room_id: room_ids, active: true).group_by(&:room_id)

    @rooms.each do |room|
      # Set preloaded associations
      room.association(:patients).target = patients_by_room[room.id] || []
      room.association(:active_room_doctors).target = active_doctors_by_room[room.id] || []
      room.association(:active_room_nurses).target = active_nurses_by_room[room.id] || []

      # Mark associations as loaded
      room.association(:patients).loaded!
      room.association(:active_room_doctors).loaded!
      room.association(:active_room_nurses).loaded!
    end
  end
end
