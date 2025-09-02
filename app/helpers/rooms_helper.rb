# Helper for optimized room display
module RoomsHelper
  # Ultra-fast room status badge with memoization
  def room_status_badge(room)
    status = room.calculate_status
    @status_badges ||= {}
    @status_badges[status] ||= case status
    when "available"
        content_tag(:span, "Available", class: "inline-block px-2 py-0.5 rounded bg-green-50 dark:bg-green-800 text-green-100 dark:text-green-100 font-bold")
    when "occupied"
        content_tag(:span, "Occupied", class: "inline-block px-2 py-0.5 rounded bg-red-50 dark:bg-red-800 text-red-100 dark:text-red-100 font-bold")
    when "patient_only"
        content_tag(:span, "Patient Only", class: "inline-block px-2 py-0.5 rounded bg-yellow-50 dark:bg-yellow-800 text-yellow-100 dark:text-yellow-100 font-bold")
    when "doctor_assigned"
        content_tag(:span, "Doctor Assigned", class: "inline-block px-2 py-0.5 rounded bg-blue-50 dark:bg-blue-800 text-blue-100 dark:text-blue-100 font-bold")
    else
        content_tag(:span, "Unknown", class: "inline-block px-2 py-0.5 rounded bg-gray-50 dark:bg-gray-800 text-gray-100 dark:text-gray-100 font-bold")
    end
  end

  # Fast room type badge
  def room_type_badge(room)
    @type_badges ||= {}
    @type_badges[room.room_type] ||= content_tag(:span, room.room_type.humanize,
      class: "inline-block px-2 py-0.5 rounded bg-blue-50 dark:bg-blue-900 text-blue-700 dark:text-blue-200 text-medium font-bold")
  end

  # Optimized capacity display with utilization range bar
  def capacity_display(room)
    patients_count = room.patients_count_cached
    utilization = room.utilization_percentage

    # Determine the color based on utilization
    bar_color_class = case utilization
    when 0..50 then "bg-green-500"
    when 51..80 then "bg-yellow-500"
    else "bg-red-500"
    end

    content_tag(:div, class: "flex items-center gap-3") do
      # Capacity number
      capacity_display = content_tag(:span, "#{patients_count}/#{room.capacity}",
        class: "text-gray-900 dark:text-white font-medium text-sm whitespace-nowrap")

      # Progress bar container
      progress_bar = content_tag(:div, class: "flex-1 bg-gray-200 dark:bg-gray-700 rounded-full h-2 min-w-[60px]") do
        content_tag(:div, "",
          class: "#{bar_color_class} h-2 rounded-full transition-all duration-300",
          style: "width: #{utilization}%")
      end

      # Percentage
      percentage_display = content_tag(:span, "#{utilization}%",
        class: "text-xs text-gray-500 dark:text-gray-400 whitespace-nowrap")

      capacity_display + progress_bar + percentage_display
    end
  end

  # Ultra-fast staff counts display
  def staff_counts_display(room)
    doctors_count = room.doctors_count_cached
    nurses_count = room.nurses_count_cached

    badges = []

    if doctors_count > 0
      badges << content_tag(:span, "#{doctors_count} Dr",
        class: "inline-flex items-center px-2 py-0.5 rounded text-xs bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200")
    end

    if nurses_count > 0
      badges << content_tag(:span, "#{nurses_count} RN",
        class: "inline-flex items-center px-2 py-0.5 rounded text-xs bg-pink-100 dark:bg-pink-900 text-pink-800 dark:text-pink-200")
    end

    if badges.empty?
      content_tag(:span, "No staff", class: "text-gray-500 dark:text-gray-400 text-xs")
    else
      safe_join(badges, " ")
    end
  end

  # Batch render room rows for maximum performance
  def render_room_rows(rooms)
    return "" if rooms.empty?

    # Pre-generate all badges to avoid repetitive calculations
    pregenerate_badges(rooms)

    rows = rooms.map do |room|
      render_single_room_row(room)
    end

    safe_join(rows)
  end

  private

  def pregenerate_badges(rooms)
    @status_badges ||= {}
    @type_badges ||= {}

    # Pre-calculate all unique statuses and types
    unique_statuses = rooms.map(&:calculate_status).uniq
    unique_types = rooms.map(&:room_type).uniq

    unique_statuses.each { |status| room_status_badge_raw(status) }
    unique_types.each { |type| room_type_badge_raw(type) }
  end

  def room_status_badge_raw(status)
    @status_badges ||= {}
    @status_badges[status] ||= case status
    when "available"
        '<span class="inline-block px-2 py-0.5 rounded bg-green-50 dark:bg-green-900 text-green-700 dark:text-green-200 font-medium">Available</span>'.html_safe
    when "occupied"
        '<span class="inline-block px-2 py-0.5 rounded bg-red-50 dark:bg-red-900 text-red-700 dark:text-red-200 font-medium">Occupied</span>'.html_safe
    when "patient_only"
        '<span class="inline-block px-2 py-0.5 rounded bg-yellow-50 dark:bg-yellow-900 text-yellow-700 dark:text-yellow-200 font-medium">Patient Only</span>'.html_safe
    when "doctor_assigned"
        '<span class="inline-block px-2 py-0.5 rounded bg-blue-50 dark:bg-blue-900 text-blue-700 dark:text-blue-200 font-medium">Doctor Assigned</span>'.html_safe
    else
        '<span class="inline-block px-2 py-0.5 rounded bg-gray-50 dark:bg-gray-900 text-gray-700 dark:text-gray-200 font-medium">Unknown</span>'.html_safe
    end
  end

  def room_type_badge_raw(type)
    @type_badges ||= {}
    @type_badges[type] ||= %Q(<span class="inline-block px-2 py-0.5 rounded bg-blue-50 dark:bg-blue-900 text-blue-700 dark:text-blue-200 font-medium">#{type.humanize}</span>).html_safe
  end

  def render_single_room_row(room)
    patients_count = room.patients_count_cached
    doctors_count = room.doctors_count_cached
    nurses_count = room.nurses_count_cached
    utilization = room.utilization_percentage

    # Use string interpolation for maximum speed
    %Q(
      <tr class="hover:bg-gray-50 dark:hover:bg-gray-800 transition">
        <td class="px-6 py-4 font-medium text-gray-900 dark:text-white">#{room.room_number}</td>
        <td class="px-6 py-4">#{@type_badges[room.room_type]}</td>
        <td class="px-6 py-4">
          <div class="flex items-center gap-3">
            <span class="text-gray-900 dark:text-white font-medium text-sm whitespace-nowrap">#{patients_count}/#{room.capacity}</span>
            <div class="flex-1 bg-gray-200 dark:bg-gray-700 rounded-full h-2 min-w-[60px]">
              <div class="#{case utilization when 0..50 then "bg-green-500" when 51..80 then "bg-yellow-500" else "bg-red-500" end} h-2 rounded-full transition-all duration-300" style="width: #{utilization}%"></div>
            </div>
            <span class="text-xs text-gray-500 dark:text-gray-400 whitespace-nowrap">#{utilization}%</span>
          </div>
        </td>
        <td class="px-6 py-4">#{@status_badges[room.calculate_status]}</td>
        <td class="px-6 py-4">
          <div class="flex gap-1">
            #{doctors_count > 0 ? %Q(<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200">#{doctors_count} Dr</span>) : ''}
            #{nurses_count > 0 ? %Q(<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-pink-100 dark:bg-pink-900 text-pink-800 dark:text-pink-200">#{nurses_count} RN</span>) : ''}
            #{doctors_count == 0 && nurses_count == 0 ? '<span class="text-gray-500 dark:text-gray-400 text-xs">No staff</span>' : ''}
          </div>
        </td>
        <td class="px-6 py-4">
          <div class="flex gap-2">
            <a href="/rooms/#{room.id}" class="text-indigo-600 dark:text-indigo-400 hover:text-indigo-900 dark:hover:text-indigo-300 text-sm font-medium">View</a>
            <a href="/rooms/#{room.id}/edit" class="text-yellow-600 dark:text-yellow-400 hover:text-yellow-900 dark:hover:text-yellow-300 text-sm font-medium">Edit</a>
          </div>
        </td>
      </tr>
    ).html_safe
  end

  def utilization_color_class(utilization)
    case utilization
    when 0..50 then "text-green-600 dark:text-green-400"
    when 51..80 then "text-yellow-600 dark:text-yellow-400"
    else "text-red-600 dark:text-red-400"
    end
  end
end
