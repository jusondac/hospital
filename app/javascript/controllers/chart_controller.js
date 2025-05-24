import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

export default class extends Controller {
  static targets = [
    "patientChart", "doctorChart", "patientTrendChart", "roomOccupancyChart",
    "patientConditionChart", "staffWorkloadChart", "monthlyTrendsChart",
    "totalPatients", "availableRooms", "activeDoctors", "onDutyNurses", "occupancyRate"
  ]

  connect() {
    console.log("Enhanced Chart controller connected")
    this.loadDashboardStats()
    this.initializePatientChart()
    this.initializeDoctorChart()
    this.initializePatientTrendChart()
    this.initializeRoomOccupancyChart()
    this.initializePatientConditionChart()
    this.initializeStaffWorkloadChart()
    this.initializeMonthlyTrendsChart()
  }

  async loadDashboardStats() {
    try {
      const response = await fetch('/api/charts/dashboard_stats')
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const stats = await response.json()

      if (this.hasTotalPatientsTarget) this.totalPatientsTarget.textContent = stats.total_patients
      if (this.hasAvailableRoomsTarget) this.availableRoomsTarget.textContent = stats.available_rooms
      if (this.hasActiveDoctorsTarget) this.activeDoctorsTarget.textContent = stats.active_doctors
      if (this.hasOnDutyNursesTarget) this.onDutyNursesTarget.textContent = stats.on_duty_nurses
      if (this.hasOccupancyRateTarget) this.occupancyRateTarget.textContent = `${stats.occupancy_rate}%`
    } catch (error) {
      console.error('Error loading dashboard stats:', error)
      // Set fallback values
      if (this.hasTotalPatientsTarget) this.totalPatientsTarget.textContent = "142"
      if (this.hasAvailableRoomsTarget) this.availableRoomsTarget.textContent = "23"
      if (this.hasActiveDoctorsTarget) this.activeDoctorsTarget.textContent = "18"
      if (this.hasOnDutyNursesTarget) this.onDutyNursesTarget.textContent = "35"
      if (this.hasOccupancyRateTarget) this.occupancyRateTarget.textContent = "78%"
    }
  }

  async initializePatientChart() {
    if (!this.hasPatientChartTarget) {
      console.warn("Patient chart target not found")
      return
    }

    console.log("Initializing patient chart")
    try {
      // Fetch real patient admission data
      const response = await fetch('/api/charts/patient_admissions')
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      const chartData = await response.json()
      console.log("Patient chart data:", chartData)

      const isDark = document.documentElement.classList.contains('dark')
      const options = {
        series: [{
          name: 'Patients',
          data: chartData.data
        }],
        chart: {
          type: 'area',
          height: 180,
          toolbar: { show: false },
          background: 'transparent',
          fontFamily: 'Inter, sans-serif'
        },
        colors: ['#4f46e5'],
        stroke: {
          curve: 'smooth',
          width: 2
        },
        fill: {
          type: 'gradient',
          gradient: {
            shadeIntensity: 1,
            opacityFrom: 0.4,
            opacityTo: 0.1,
            stops: [0, 90, 100]
          }
        },
        xaxis: {
          categories: chartData.labels,
          labels: {
            style: {
              colors: isDark ? '#9CA3AF' : '#6B7280',
              fontSize: '11px',
              fontWeight: 500
            }
          },
          axisBorder: { show: false },
          axisTicks: { show: false }
        },
        yaxis: {
          labels: {
            style: {
              colors: isDark ? '#9CA3AF' : '#6B7280',
              fontSize: '11px',
              fontWeight: 500
            }
          }
        },
        tooltip: {
          theme: isDark ? 'dark' : 'light',
          style: { fontSize: '12px' }
        },
        dataLabels: { enabled: false },
        grid: {
          show: true,
          borderColor: isDark ? '#374151' : '#E5E7EB',
          strokeDashArray: 3,
          xaxis: { lines: { show: false } },
          yaxis: { lines: { show: true } }
        }
      }

      console.log("Creating patient chart with options:", options)
      const chart = new ApexCharts(this.patientChartTarget, options)
      chart.render()
    } catch (error) {
      console.error('Error loading patient chart data:', error)
      // Fallback to dummy data if API fails
      this.renderFallbackPatientChart()
    }
  }

  renderFallbackPatientChart() {
    console.log("Rendering fallback patient chart")
    const isDark = document.documentElement.classList.contains('dark')
    const options = {
      series: [{
        name: 'Patients',
        data: [28, 35, 42, 30, 45, 38, 50]
      }],
      chart: {
        type: 'area',
        height: 180,
        toolbar: { show: false },
        background: 'transparent',
        fontFamily: 'Inter, sans-serif'
      },
      colors: ['#4f46e5'],
      stroke: {
        curve: 'smooth',
        width: 2
      },
      fill: {
        type: 'gradient',
        gradient: {
          shadeIntensity: 1,
          opacityFrom: 0.4,
          opacityTo: 0.1,
          stops: [0, 90, 100]
        }
      },
      xaxis: {
        categories: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        labels: {
          style: {
            colors: isDark ? '#9CA3AF' : '#6B7280',
            fontSize: '11px',
            fontWeight: 500
          }
        },
        axisBorder: { show: false },
        axisTicks: { show: false }
      },
      yaxis: {
        labels: {
          style: {
            colors: isDark ? '#9CA3AF' : '#6B7280',
            fontSize: '11px',
            fontWeight: 500
          }
        }
      },
      tooltip: {
        theme: isDark ? 'dark' : 'light',
        style: { fontSize: '12px' }
      },
      dataLabels: { enabled: false },
      grid: {
        show: true,
        borderColor: isDark ? '#374151' : '#E5E7EB',
        strokeDashArray: 3,
        xaxis: { lines: { show: false } },
        yaxis: { lines: { show: true } }
      }
    }

    const chart = new ApexCharts(this.patientChartTarget, options)
    chart.render()
  }

  async initializeDoctorChart() {
    if (!this.hasDoctorChartTarget) {
      console.warn("Doctor chart target not found")
      return
    }

    console.log("Initializing doctor chart")
    try {
      // Fetch real doctor specialty data
      const response = await fetch('/api/charts/doctor_specialties')
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      const chartData = await response.json()
      console.log("Doctor chart data:", chartData)

      const isDark = document.documentElement.classList.contains('dark')
      const options = {
        series: chartData.data,
        chart: {
          type: 'donut',
          height: 220,
          toolbar: { show: false },
          background: 'transparent',
          fontFamily: 'Inter, sans-serif'
        },
        colors: ['#4f46e5', '#3b82f6', '#8b5cf6', '#ec4899', '#10b981'],
        labels: chartData.labels,
        legend: {
          position: 'bottom',
          fontSize: '12px',
          fontWeight: 500,
          labels: {
            colors: isDark ? '#9CA3AF' : '#6B7280',
            useSeriesColors: false
          },
          markers: {
            width: 8,
            height: 8,
            radius: 2
          }
        },
        plotOptions: {
          pie: {
            donut: {
              size: '65%',
              labels: {
                show: true,
                name: {
                  show: true,
                  fontSize: '14px',
                  fontWeight: 600,
                  color: isDark ? '#F9FAFB' : '#111827'
                },
                value: {
                  show: true,
                  fontSize: '20px',
                  fontWeight: 700,
                  color: isDark ? '#F9FAFB' : '#111827'
                },
                total: {
                  show: true,
                  showAlways: true,
                  label: 'Total',
                  fontSize: '12px',
                  fontWeight: 500,
                  color: isDark ? '#9CA3AF' : '#6B7280'
                }
              }
            }
          }
        },
        dataLabels: { enabled: false },
        stroke: { width: 0 },
        tooltip: {
          theme: isDark ? 'dark' : 'light',
          style: { fontSize: '12px' }
        }
      }

      console.log("Creating doctor chart with options:", options)
      const chart = new ApexCharts(this.doctorChartTarget, options)
      chart.render()
    } catch (error) {
      console.error('Error loading doctor chart data:', error)
      // Fallback to dummy data if API fails
      this.renderFallbackDoctorChart()
    }
  }

  renderFallbackDoctorChart() {
    console.log("Rendering fallback doctor chart")
    const isDark = document.documentElement.classList.contains('dark')
    const options = {
      series: [12, 8, 10, 7, 5],
      chart: {
        type: 'donut',
        height: 220,
        toolbar: { show: false },
        background: 'transparent',
        fontFamily: 'Inter, sans-serif'
      },
      colors: ['#4f46e5', '#3b82f6', '#8b5cf6', '#ec4899', '#10b981'],
      labels: ['Surgery', 'Pediatrics', 'Cardiology', 'Neurology', 'Oncology'],
      legend: {
        position: 'bottom',
        fontSize: '12px',
        fontWeight: 500,
        labels: {
          colors: isDark ? '#9CA3AF' : '#6B7280',
          useSeriesColors: false
        },
        markers: {
          width: 8,
          height: 8,
          radius: 2
        }
      },
      plotOptions: {
        pie: {
          donut: {
            size: '65%',
            labels: {
              show: true,
              name: {
                show: true,
                fontSize: '14px',
                fontWeight: 600,
                color: isDark ? '#F9FAFB' : '#111827'
              },
              value: {
                show: true,
                fontSize: '20px',
                fontWeight: 700,
                color: isDark ? '#F9FAFB' : '#111827'
              },
              total: {
                show: true,
                showAlways: true,
                label: 'Total',
                fontSize: '12px',
                fontWeight: 500,
                color: isDark ? '#9CA3AF' : '#6B7280'
              }
            }
          }
        }
      },
      dataLabels: { enabled: false },
      stroke: { width: 0 },
      tooltip: {
        theme: isDark ? 'dark' : 'light',
        style: { fontSize: '12px' }
      }
    }

    const chart = new ApexCharts(this.doctorChartTarget, options)
    chart.render()
  }

  async initializePatientTrendChart() {
    if (!this.hasPatientTrendChartTarget) return

    try {
      const response = await fetch('/api/charts/patient_trend')
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const chartData = await response.json()

      const isDark = document.documentElement.classList.contains('dark')
      const options = {
        series: [{
          name: 'Admissions',
          data: chartData.admissions
        }, {
          name: 'Discharges',
          data: chartData.discharges
        }],
        chart: {
          type: 'line',
          height: 280,
          toolbar: { show: false },
          background: 'transparent',
          fontFamily: 'Inter, sans-serif'
        },
        colors: ['#4f46e5', '#10b981'],
        stroke: {
          curve: 'smooth',
          width: 2.5
        },
        markers: {
          size: 0,
          hover: { size: 6 }
        },
        xaxis: {
          categories: chartData.labels,
          labels: {
            style: {
              colors: isDark ? '#9CA3AF' : '#6B7280',
              fontSize: '11px',
              fontWeight: 500
            }
          },
          axisBorder: { show: false },
          axisTicks: { show: false }
        },
        yaxis: {
          labels: {
            style: {
              colors: isDark ? '#9CA3AF' : '#6B7280',
              fontSize: '11px',
              fontWeight: 500
            }
          }
        },
        grid: {
          show: true,
          borderColor: isDark ? '#374151' : '#E5E7EB',
          strokeDashArray: 3,
          xaxis: { lines: { show: false } },
          yaxis: { lines: { show: true } }
        },
        tooltip: {
          theme: isDark ? 'dark' : 'light',
          style: { fontSize: '12px' }
        },
        legend: {
          position: 'top',
          horizontalAlign: 'right',
          fontSize: '12px',
          fontWeight: 500,
          labels: {
            colors: isDark ? '#F3F4F6' : '#374151'
          },
          markers: {
            width: 8,
            height: 8,
            radius: 2
          }
        }
      }

      new ApexCharts(this.patientTrendChartTarget, options).render()
    } catch (error) {
      console.error('Error loading patient trend chart:', error)
      this.renderFallbackPatientTrendChart()
    }
  }

  renderFallbackPatientTrendChart() {
    const options = {
      series: [{
        name: 'Admissions',
        data: [12, 15, 18, 14, 22, 19, 25, 20, 16, 18, 21, 24, 19, 17, 20, 23, 26, 22, 18, 21, 25, 20, 17, 19, 22, 24, 21, 18, 20, 23]
      }, {
        name: 'Discharges',
        data: [8, 12, 14, 11, 18, 15, 20, 16, 13, 15, 17, 19, 15, 14, 16, 18, 21, 17, 14, 16, 20, 16, 13, 15, 17, 19, 16, 14, 16, 18]
      }],
      chart: {
        type: 'line',
        height: 300,
        toolbar: { show: false }
      },
      colors: ['#4f46e5', '#10b981'],
      stroke: { curve: 'smooth', width: 3 },
      xaxis: {
        categories: Array.from({ length: 30 }, (_, i) => `Day ${i + 1}`)
      }
    }
    new ApexCharts(this.patientTrendChartTarget, options).render()
  }

  async initializeRoomOccupancyChart() {
    if (!this.hasRoomOccupancyChartTarget) return

    try {
      const response = await fetch('/api/charts/room_occupancy')
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const chartData = await response.json()

      const options = {
        series: [{
          name: 'Occupied',
          type: 'column',
          data: chartData.occupied
        }, {
          name: 'Capacity',
          type: 'line',
          data: chartData.capacity
        }],
        chart: {
          type: 'line',
          height: 250,
          toolbar: { show: false },
          background: 'transparent'
        },
        colors: ['#3b82f6', '#f59e0b'],
        stroke: {
          width: [0, 3],
          curve: 'smooth'
        },
        plotOptions: {
          bar: {
            columnWidth: '50%',
            borderRadius: 4
          }
        },
        xaxis: {
          categories: chartData.labels,
          labels: {
            style: {
              colors: this.isDarkMode() ? '#9CA3AF' : '#6B7280',
              fontSize: '12px'
            }
          }
        },
        yaxis: {
          labels: {
            style: {
              colors: this.isDarkMode() ? '#9CA3AF' : '#6B7280',
              fontSize: '12px'
            }
          }
        },
        grid: {
          borderColor: this.isDarkMode() ? '#374151' : '#E5E7EB',
          strokeDashArray: 3
        },
        tooltip: {
          theme: this.isDarkMode() ? 'dark' : 'light'
        },
        legend: {
          labels: {
            colors: this.isDarkMode() ? '#F3F4F6' : '#374151'
          }
        }
      }

      new ApexCharts(this.roomOccupancyChartTarget, options).render()
    } catch (error) {
      console.error('Error loading room occupancy chart:', error)
      this.renderFallbackRoomOccupancyChart()
    }
  }

  renderFallbackRoomOccupancyChart() {
    const options = {
      series: [{
        name: 'Occupied',
        type: 'column',
        data: [45, 52, 38, 24, 33, 26, 21]
      }, {
        name: 'Capacity',
        type: 'line',
        data: [60, 60, 60, 60, 60, 60, 60]
      }],
      chart: {
        type: 'line',
        height: 250,
        toolbar: { show: false }
      },
      colors: ['#3b82f6', '#f59e0b'],
      stroke: { width: [0, 3] },
      xaxis: {
        categories: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      }
    }
    new ApexCharts(this.roomOccupancyChartTarget, options).render()
  }

  async initializePatientConditionChart() {
    if (!this.hasPatientConditionChartTarget) return

    try {
      const response = await fetch('/api/charts/patient_conditions')
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const chartData = await response.json()

      const options = {
        series: chartData.data,
        chart: {
          type: 'pie',
          height: 250,
          toolbar: { show: false },
          background: 'transparent'
        },
        colors: ['#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4'],
        labels: chartData.labels,
        legend: {
          position: 'bottom',
          labels: {
            colors: this.isDarkMode() ? '#F3F4F6' : '#374151'
          }
        },
        dataLabels: {
          enabled: true,
          style: {
            colors: ['#fff']
          }
        },
        tooltip: {
          theme: this.isDarkMode() ? 'dark' : 'light'
        }
      }

      new ApexCharts(this.patientConditionChartTarget, options).render()
    } catch (error) {
      console.error('Error loading patient condition chart:', error)
      this.renderFallbackPatientConditionChart()
    }
  }

  renderFallbackPatientConditionChart() {
    const options = {
      series: [45, 25, 15, 10, 5],
      chart: {
        type: 'pie',
        height: 250,
        toolbar: { show: false }
      },
      colors: ['#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4'],
      labels: ['Stable', 'Critical', 'Recovering', 'Observation', 'Emergency']
    }
    new ApexCharts(this.patientConditionChartTarget, options).render()
  }

  async initializeStaffWorkloadChart() {
    if (!this.hasStaffWorkloadChartTarget) return

    try {
      const response = await fetch('/api/charts/staff_workload')
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const chartData = await response.json()

      const options = {
        series: [{
          name: 'Patients per Doctor',
          data: chartData.doctors
        }, {
          name: 'Patients per Nurse',
          data: chartData.nurses
        }],
        chart: {
          type: 'bar',
          height: 300,
          toolbar: { show: false },
          background: 'transparent'
        },
        colors: ['#4f46e5', '#10b981'],
        plotOptions: {
          bar: {
            horizontal: false,
            columnWidth: '55%',
            borderRadius: 4
          }
        },
        dataLabels: {
          enabled: false
        },
        xaxis: {
          categories: chartData.specialties,
          labels: {
            style: {
              colors: this.isDarkMode() ? '#9CA3AF' : '#6B7280',
              fontSize: '12px'
            }
          }
        },
        yaxis: {
          labels: {
            style: {
              colors: this.isDarkMode() ? '#9CA3AF' : '#6B7280',
              fontSize: '12px'
            }
          }
        },
        grid: {
          borderColor: this.isDarkMode() ? '#374151' : '#E5E7EB',
          strokeDashArray: 3
        },
        tooltip: {
          theme: this.isDarkMode() ? 'dark' : 'light'
        },
        legend: {
          labels: {
            colors: this.isDarkMode() ? '#F3F4F6' : '#374151'
          }
        }
      }

      new ApexCharts(this.staffWorkloadChartTarget, options).render()
    } catch (error) {
      console.error('Error loading staff workload chart:', error)
      this.renderFallbackStaffWorkloadChart()
    }
  }

  renderFallbackStaffWorkloadChart() {
    const options = {
      series: [{
        name: 'Patients per Doctor',
        data: [8, 12, 6, 10, 7]
      }, {
        name: 'Patients per Nurse',
        data: [4, 6, 3, 5, 4]
      }],
      chart: {
        type: 'bar',
        height: 300,
        toolbar: { show: false }
      },
      colors: ['#4f46e5', '#10b981'],
      xaxis: {
        categories: ['Surgery', 'Pediatrics', 'Cardiology', 'Neurology', 'Oncology']
      }
    }
    new ApexCharts(this.staffWorkloadChartTarget, options).render()
  }

  async initializeMonthlyTrendsChart() {
    if (!this.hasMonthlyTrendsChartTarget) return

    try {
      const response = await fetch('/api/charts/monthly_trends')
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const chartData = await response.json()

      const options = {
        series: [{
          name: 'Admissions',
          type: 'area',
          data: chartData.admissions
        }, {
          name: 'Discharges',
          type: 'line',
          data: chartData.discharges
        }, {
          name: 'Transfers',
          type: 'line',
          data: chartData.transfers
        }],
        chart: {
          type: 'line',
          height: 300,
          toolbar: { show: false },
          background: 'transparent'
        },
        colors: ['#4f46e5', '#10b981', '#f59e0b'],
        stroke: {
          width: [0, 3, 3],
          curve: 'smooth'
        },
        fill: {
          type: ['gradient', 'solid', 'solid'],
          gradient: {
            shadeIntensity: 1,
            opacityFrom: 0.7,
            opacityTo: 0.3
          }
        },
        xaxis: {
          categories: chartData.months,
          labels: {
            style: {
              colors: this.isDarkMode() ? '#9CA3AF' : '#6B7280',
              fontSize: '12px'
            }
          }
        },
        yaxis: {
          labels: {
            style: {
              colors: this.isDarkMode() ? '#9CA3AF' : '#6B7280',
              fontSize: '12px'
            }
          }
        },
        grid: {
          borderColor: this.isDarkMode() ? '#374151' : '#E5E7EB',
          strokeDashArray: 3
        },
        tooltip: {
          theme: this.isDarkMode() ? 'dark' : 'light'
        },
        legend: {
          labels: {
            colors: this.isDarkMode() ? '#F3F4F6' : '#374151'
          }
        }
      }

      new ApexCharts(this.monthlyTrendsChartTarget, options).render()
    } catch (error) {
      console.error('Error loading monthly trends chart:', error)
      this.renderFallbackMonthlyTrendsChart()
    }
  }

  renderFallbackMonthlyTrendsChart() {
    const options = {
      series: [{
        name: 'Admissions',
        type: 'area',
        data: [120, 135, 110, 125, 140, 155]
      }, {
        name: 'Discharges',
        type: 'line',
        data: [115, 130, 105, 120, 135, 145]
      }, {
        name: 'Transfers',
        type: 'line',
        data: [15, 20, 12, 18, 25, 22]
      }],
      chart: {
        type: 'line',
        height: 300,
        toolbar: { show: false }
      },
      colors: ['#4f46e5', '#10b981', '#f59e0b'],
      stroke: { width: [0, 3, 3] },
      xaxis: {
        categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
      }
    }
    new ApexCharts(this.monthlyTrendsChartTarget, options).render()
  }

  isDarkMode() {
    return document.documentElement.classList.contains('dark')
  }
}
