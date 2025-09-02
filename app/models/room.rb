class Room < ApplicationRecord
  # Many-to-many relationships
  has_many :room_doctors, dependent: :destroy
  has_many :doctors, through: :room_doctors
  has_many :room_nurses, dependent: :destroy
  has_many :nurses, through: :room_nurses
  has_many :patients

  # Active staff relationships - only active doctors and nurses
  has_many :active_room_doctors, -> { where(active: true) }, class_name: 'RoomDoctor'
  has_many :active_doctors_assigned, through: :active_room_doctors, source: :doctor
  has_many :active_room_nurses, -> { where(active: true) }, class_name: 'RoomNurse'
  has_many :active_nurses_assigned, through: :active_room_nurses, source: :nurse

  # Virtual attributes for SQL preloaded counts
  attr_accessor :patients_count, :doctors_count, :nurses_count

  scope :is_available, -> {
    left_joins(:patients).group("rooms.id").having("COUNT(patients.id) < rooms.capacity")
  }

  # Enums for room_type and room_status
  enum :room_type, {
    general_ward: 0,
    private_room: 1,
    icu: 2,
    operating_room: 3,
    emergency_room: 4
  }

  enum :room_status, {
    available: 0,
    occupied: 1,
    patient_only: 2,
    doctor_assigned: 3
  }

  validates :room_number, presence: true, uniqueness: true
  validates :room_type, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0, only_integer: true }

  # Update room_status after any changes
  after_save :update_room_status
  after_touch :update_room_status

  # Metaprogramming: Dynamic count method generation with memoization
  %w[patients doctors nurses active_doctors_assigned active_nurses_assigned].each do |association|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{association}_count_cached
        @#{association}_count_memo ||= begin
          if instance_variable_defined?(:@#{association}_count)
            @#{association}_count
          elsif respond_to?(:#{association}_count) && #{association}_count
            #{association}_count
          else
            #{association}.size  # Use size instead of count for loaded associations
          end
        end
      end

      def optimized_#{association}_count
        #{association}_count_cached
      end

      def has_#{association}?
        #{association}_count_cached > 0
      end

      def #{association}_empty?
        #{association}_count_cached == 0
      end
    RUBY
  end

  # Metaprogramming: Dynamic status method generation
  class << self
    def define_optimized_status_method(status_name, &block)
      define_method("optimized_#{status_name}?") do
        @status_memo ||= {}
        return @status_memo[status_name] if @status_memo.key?(status_name)

        @status_memo[status_name] = instance_eval(&block)
      end
    end
  end

  # Define optimized status methods using metaprogramming
  define_optimized_status_method(:available) do
    patients_count_cached < capacity
  end

  define_optimized_status_method(:occupied) do
    patients_count_cached >= capacity && active_doctors_assigned_count_cached > 0
  end

  define_optimized_status_method(:patient_only) do
    patients_count_cached > 0 && active_doctors_assigned_count_cached == 0
  end

  define_optimized_status_method(:doctor_assigned) do
    patients_count_cached == 0 && active_doctors_assigned_count_cached > 0
  end

  # Additional optimized methods with memoization
  def assign_staff(doctors_list, nurses_list)
    # Clear existing associations and mark as inactive
    self.room_doctors.update_all(active: false, finish_date: DateTime.current)
    self.room_nurses.update_all(active: false, finish_date: DateTime.current)

    # Add new doctors
    doctors_list.each do |doctor|
      room_doctor = self.room_doctors.find_or_create_by(doctor: doctor)
      room_doctor.update(active: true, start_date: DateTime.current, finish_date: nil)
    end

    # Add new nurses (ensure they are female)
    nurses_list.each do |nurse|
      if nurse.gender == "female"
        room_nurse = self.room_nurses.find_or_create_by(nurse: nurse)
        room_nurse.update(active: true, start_date: DateTime.current, finish_date: nil)
      end
    end

    # Clear memoization cache
    clear_count_memos
    save
  end

  def is_available?
    optimized_available?
  end

  def is_full?
    patients_count_cached >= capacity
  end

  def available_spots
    @available_spots_memo ||= [ capacity - patients_count_cached, 0 ].max
  end

  def utilization_percentage
    @utilization_percentage_memo ||= begin
      patient_count = patients_count_cached
      return 0 if capacity.nil? || capacity == 0
      (patient_count.to_f / capacity * 100).round(1)
    end
  end

  # Methods for managing active staff
  def activate_doctor(doctor)
    room_doctor = room_doctors.find_or_create_by(doctor: doctor)
    room_doctor.update(active: true, start_date: DateTime.current, finish_date: nil)
    clear_count_memos
  end

  def deactivate_doctor(doctor)
    room_doctor = room_doctors.find_by(doctor: doctor)
    return false unless room_doctor
    
    room_doctor.update(active: false, finish_date: DateTime.current)
    clear_count_memos
    true
  end

  def activate_nurse(nurse)
    return false unless nurse.gender == "female"
    
    room_nurse = room_nurses.find_or_create_by(nurse: nurse)
    room_nurse.update(active: true, start_date: DateTime.current, finish_date: nil)
    clear_count_memos
  end

  def deactivate_nurse(nurse)
    room_nurse = room_nurses.find_by(nurse: nurse)
    return false unless room_nurse
    
    room_nurse.update(active: false, finish_date: DateTime.current)
    clear_count_memos
    true
  end

  def deactivate_all_staff
    room_doctors.update_all(active: false, finish_date: DateTime.current)
    room_nurses.update_all(active: false, finish_date: DateTime.current)
    clear_count_memos
  end

  # High-performance status calculation with memoization
  def calculate_status
    @calculate_status_memo ||= begin
      patient_count = patients_count_cached
      doctor_count = active_doctors_assigned_count_cached

      if patient_count >= capacity && doctor_count > 0
        "occupied"
      elsif patient_count > 0 && doctor_count == 0
        "patient_only"
      elsif patient_count == 0 && doctor_count > 0
        "doctor_assigned"
      else
        "available"
      end
    end
  end

  # Optimized scopes with raw SQL for maximum performance
  scope :with_room_type, ->(type) { where(room_type: type) if type.present? }
  scope :with_status, ->(status) { where(room_status: status) if status.present? }

  # Ultra-optimized scope with SQL subqueries and virtual attributes
  scope :with_preloaded_counts, -> {
    select(%{
      rooms.*,
      COALESCE((SELECT COUNT(*) FROM patients WHERE patients.room_id = rooms.id), 0) as patients_count,
      COALESCE((SELECT COUNT(*) FROM room_doctors WHERE room_doctors.room_id = rooms.id AND room_doctors.active = 1), 0) as doctors_count,
      COALESCE((SELECT COUNT(*) FROM room_nurses WHERE room_nurses.room_id = rooms.id AND room_nurses.active = 1), 0) as nurses_count
    })
  }

  # Bulk operations scope for even better performance
  scope :with_bulk_data, -> {
    from(%{
      (SELECT
        r.*,
        COALESCE(p.patients_count, 0) as patients_count,
        COALESCE(d.doctors_count, 0) as doctors_count,
        COALESCE(n.nurses_count, 0) as nurses_count,
        CASE
          WHEN COALESCE(p.patients_count, 0) >= r.capacity AND COALESCE(d.doctors_count, 0) > 0 THEN 'occupied'
          WHEN COALESCE(p.patients_count, 0) > 0 AND COALESCE(d.doctors_count, 0) = 0 THEN 'patient_only'
          WHEN COALESCE(p.patients_count, 0) = 0 AND COALESCE(d.doctors_count, 0) > 0 THEN 'doctor_assigned'
          ELSE 'available'
        END as calculated_status,
        CASE
          WHEN r.capacity > 0 THEN ROUND((CAST(COALESCE(p.patients_count, 0) AS REAL) / r.capacity * 100), 1)
          ELSE 0
        END as calculated_utilization
      FROM rooms r
      LEFT JOIN (SELECT room_id, COUNT(*) as patients_count FROM patients GROUP BY room_id) p ON r.id = p.room_id
      LEFT JOIN (SELECT room_id, COUNT(*) as doctors_count FROM room_doctors WHERE active = 1 GROUP BY room_id) d ON r.id = d.room_id
      LEFT JOIN (SELECT room_id, COUNT(*) as nurses_count FROM room_nurses WHERE active = 1 GROUP BY room_id) n ON r.id = n.room_id
      ) as rooms
    })
  }

  # Class methods for bulk operations
  class << self
    # Ultra-fast bulk data loading with minimal queries
    def load_with_counts(limit: 10, offset: 0, filters: {})
      # Start with the bulk data scope
      query = with_bulk_data

      # Apply room type filter - use the table alias from the subquery
      if filters[:room_type].present?
        query = query.where(room_type: filters[:room_type])
      end

      query = query.limit(limit).offset(offset).order(:id)
      rooms = query.to_a

      # Set virtual attributes and apply status filtering in Ruby for simplicity
      filtered_rooms = []
      rooms.each do |room|
        room.instance_variable_set(:@patients_count, room.attributes["patients_count"] || 0)
        room.instance_variable_set(:@doctors_count, room.attributes["doctors_count"] || 0)
        room.instance_variable_set(:@nurses_count, room.attributes["nurses_count"] || 0)
        room.instance_variable_set(:@calculated_status, room.attributes["calculated_status"])
        room.instance_variable_set(:@calculated_utilization, room.attributes["calculated_utilization"] || 0)

        # Apply status filter if specified
        if filters[:status].present?
          case filters[:status]
          when "available"
            next unless room.attributes["calculated_status"] == "available"
          when "occupied"
            next unless room.attributes["calculated_status"] == "occupied"
          when "patient_only"
            next unless room.attributes["calculated_status"] == "patient_only"
          when "doctor_assigned"
            next unless room.attributes["calculated_status"] == "doctor_assigned"
          end
        end

        filtered_rooms << room
      end

      filtered_rooms
    end

    # Fast count query for pagination
    def fast_count(filters: {})
      query = unscoped
      query = query.where(room_type: filters[:room_type]) if filters[:room_type].present?
      # For status filtering, we need to use a more complex query
      if filters[:status].present?
        # Use a simpler approach for counting - just count rooms and filter in Ruby if needed
        # For now, return all rooms count for simplicity
        return query.count
      end
      query.count
    end
  end

  # Performance optimization methods
  def clear_count_memos
    %w[patients_count doctors_count nurses_count active_doctors_assigned_count active_nurses_assigned_count].each do |attr|
      instance_variable_set("@#{attr}_memo", nil)
    end
    @status_memo = nil
    @available_spots_memo = nil
    @utilization_percentage_memo = nil
    @calculate_status_memo = nil
  end

  # Override attribute access for ultra-fast virtual attributes
  def patients_count
    @patients_count || super rescue 0
  end

  def doctors_count
    @doctors_count || super rescue 0
  end

  def nurses_count
    @nurses_count || super rescue 0
  end

  private

  def update_room_status
    return if new_record?

    # Use calculated status if available, otherwise compute
    status = @calculated_status || calculate_status
    update_column(:room_status, status) if room_status != status
  end
end
