import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

export default class extends Controller {
  static targets = ["patientChart", "doctorChart"]

  connect() {
    console.log("Chart controller connected")
    this.initializePatientChart()
    this.initializeDoctorChart()
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

      const options = {
        series: [{
          name: 'Patients',
          data: chartData.data
        }],
        chart: {
          type: 'area',
          height: 200,
          toolbar: {
            show: false
          }
        },
        colors: ['#4f46e5'],
        stroke: {
          curve: 'smooth',
          width: 2
        },
        xaxis: {
          categories: chartData.labels
        },
        tooltip: {
          theme: document.documentElement.classList.contains('dark') ? 'dark' : 'light'
        },
        dataLabels: {
          enabled: false
        },
        grid: {
          show: false
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
    const options = {
      series: [{
        name: 'Patients',
        data: [28, 35, 42, 30, 45, 38, 50]
      }],
      chart: {
        type: 'area',
        height: 200,
        toolbar: {
          show: false
        }
      },
      colors: ['#4f46e5'],
      stroke: {
        curve: 'smooth',
        width: 2
      },
      xaxis: {
        categories: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      },
      tooltip: {
        theme: document.documentElement.classList.contains('dark') ? 'dark' : 'light'
      },
      dataLabels: {
        enabled: false
      },
      grid: {
        show: false
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

      const options = {
        series: chartData.data,
        chart: {
          type: 'donut',
          height: 200,
          toolbar: {
            show: false
          }
        },
        colors: ['#4f46e5', '#3b82f6', '#8b5cf6', '#ec4899', '#10b981'],
        labels: chartData.labels,
        legend: {
          position: 'bottom'
        },
        dataLabels: {
          enabled: false
        },
        tooltip: {
          theme: document.documentElement.classList.contains('dark') ? 'dark' : 'light'
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
    const options = {
      series: [12, 8, 10, 7, 5],
      chart: {
        type: 'donut',
        height: 200,
        toolbar: {
          show: false
        }
      },
      colors: ['#4f46e5', '#3b82f6', '#8b5cf6', '#ec4899', '#10b981'],
      labels: ['Surgery', 'Pediatrics', 'Cardiology', 'Neurology', 'Oncology'],
      legend: {
        position: 'bottom'
      },
      dataLabels: {
        enabled: false
      },
      tooltip: {
        theme: document.documentElement.classList.contains('dark') ? 'dark' : 'light'
      }
    }

    const chart = new ApexCharts(this.doctorChartTarget, options)
    chart.render()
  }
}
