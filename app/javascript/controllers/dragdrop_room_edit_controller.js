import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="dragdrop-room-edit"
export default class extends Controller {
  static targets = [
    "doctorsList", "assignedDoctors", "doctorSearch",
    "nursesList", "assignedNurses", "nurseSearch",
    "hiddenFields"
  ]
  static values = {
    assignedDoctors: Array,
    assignedNurses: Array
  }

  connect() {
    // Convert all IDs to strings for consistency
    this.assignedDoctorIds = this.assignedDoctorsValue.map(id => String(id))
    this.assignedNurseIds = this.assignedNursesValue.map(id => String(id))

    console.log('Initial assigned doctor IDs:', this.assignedDoctorIds)
    console.log('Initial assigned nurse IDs:', this.assignedNurseIds)

    this.initializeSortables()
    this.renderAssignedStaff()
    this.updateHiddenFields()
  }

  initializeSortables() {
    // Doctors list - source (draggable)
    if (this.hasDoctorsListTarget) {
      Sortable.create(this.doctorsListTarget, {
        group: {
          name: "doctors",
          pull: "clone",
          put: false
        },
        animation: 150,
        sort: false,
        onEnd: (evt) => {
          if (evt.clone) {
            evt.clone.remove()
          }
        }
      })
    }

    // Assigned doctors - destination (droppable and sortable)
    if (this.hasAssignedDoctorsTarget) {
      Sortable.create(this.assignedDoctorsTarget, {
        group: "doctors",
        animation: 150, onAdd: (evt) => {
          const doctorCard = evt.item
          const doctorId = String(doctorCard.dataset.doctorId)

          console.log('Doctor dropped with ID:', doctorId, 'Type:', typeof doctorId)
          console.log('Current assigned doctors:', this.assignedDoctorIds)

          if (!this.assignedDoctorIds.includes(doctorId)) {
            // Store doctor data before removing the card
            const doctorData = {
              id: doctorId,
              name: doctorCard.dataset.doctorName,
              specialization: doctorCard.dataset.doctorSpecialization,
              nursesCount: doctorCard.dataset.nursesCount
            }

            // Store the doctor data for later use
            if (!this.doctorDataCache) this.doctorDataCache = {}
            this.doctorDataCache[doctorId] = doctorData

            this.assignedDoctorIds.push(doctorId)
            this.updateHiddenFields()

            // Auto-add doctor's nurses
            this.addDoctorNurses(doctorId)

            // Re-render after adding nurses
            this.renderAssignedDoctors()
          }

          // Remove the dragged element since we're re-rendering
          doctorCard.remove()
        }
      })
    }

    // Nurses list - source (draggable)
    if (this.hasNursesListTarget) {
      Sortable.create(this.nursesListTarget, {
        group: {
          name: "nurses",
          pull: "clone",
          put: false
        },
        animation: 150,
        sort: false,
        onEnd: (evt) => {
          if (evt.clone) {
            evt.clone.remove()
          }
        }
      })
    }

    // Assigned nurses - destination (droppable and sortable)
    if (this.hasAssignedNursesTarget) {
      Sortable.create(this.assignedNursesTarget, {
        group: "nurses",
        animation: 150, onAdd: (evt) => {
          const nurseCard = evt.item
          const nurseId = String(nurseCard.dataset.nurseId)

          console.log('Nurse dropped with ID:', nurseId, 'Type:', typeof nurseId)
          console.log('Current assigned nurses:', this.assignedNurseIds)

          if (!this.assignedNurseIds.includes(nurseId)) {
            // Store nurse data before removing the card
            const nurseData = {
              id: nurseId,
              name: nurseCard.dataset.nurseName,
              specialization: nurseCard.dataset.nurseSpecialization,
              doctor: nurseCard.dataset.nurseDoctor
            }

            // Store the nurse data for later use
            if (!this.nurseDataCache) this.nurseDataCache = {}
            this.nurseDataCache[nurseId] = nurseData

            this.assignedNurseIds.push(nurseId)
            this.renderAssignedNurses()
            this.updateHiddenFields()
          }

          // Remove the dragged element since we're re-rendering
          nurseCard.remove()
        }
      })
    }
  } async addDoctorNurses(doctorId) {
    try {
      const response = await fetch(`/api/doctors/${doctorId}/nurses`)
      if (response.ok) {
        const data = await response.json()

        console.log('Fetched nurses for doctor:', data.nurses)

        // Initialize nurse cache if not exists
        if (!this.nurseDataCache) this.nurseDataCache = {}

        data.nurses.forEach(nurse => {
          const nurseIdStr = String(nurse.id)
          if (!this.assignedNurseIds.includes(nurseIdStr)) {
            this.assignedNurseIds.push(nurseIdStr)

            // Cache the nurse data for rendering
            this.nurseDataCache[nurseIdStr] = {
              id: nurseIdStr,
              name: nurse.name,
              specialization: nurse.specialization,
              doctor: nurse.doctor ? nurse.doctor.name : 'Unknown'
            }

            console.log('Auto-added nurse ID:', nurseIdStr)
          }
        })

        this.renderAssignedStaff()
        this.updateHiddenFields()
      }
    } catch (error) {
      console.error('Error fetching doctor nurses:', error)
    }
  }

  renderAssignedStaff() {
    this.renderAssignedDoctors()
    this.renderAssignedNurses()
  }

  renderAssignedDoctors() {
    if (!this.hasAssignedDoctorsTarget) return

    if (this.assignedDoctorIds.length === 0) {
      this.assignedDoctorsTarget.innerHTML = `
        <div class="text-center text-gray-500 py-8 border-2 border-dashed border-gray-600 rounded-lg h-full flex flex-col items-center justify-center">
          <div class="text-sm">Drop doctors here</div>
          <div class="text-xs mt-1">Drag doctors from the left to assign them</div>
        </div>
      `
      return
    }

    // Get doctor data from the available doctors list or cache
    const doctorCards = []
    this.assignedDoctorIds.forEach(doctorId => {
      const originalCard = this.doctorsListTarget.querySelector(`[data-doctor-id="${doctorId}"]`)
      if (originalCard) {
        doctorCards.push({
          id: doctorId,
          name: originalCard.dataset.doctorName,
          specialization: originalCard.dataset.doctorSpecialization,
          nursesCount: originalCard.dataset.nursesCount
        })
      } else if (this.doctorDataCache && this.doctorDataCache[doctorId]) {
        // Use cached data if original card is not available
        doctorCards.push(this.doctorDataCache[doctorId])
      }
    })

    this.assignedDoctorsTarget.innerHTML = doctorCards.map(doctor => `
      <div class="doctor-card bg-green-700 p-3 mb-3 rounded-lg border border-green-500"
           data-doctor-id="${doctor.id}">
        <div class="flex justify-between items-start">
          <div class="flex-1">
            <div class="text-white font-medium">${doctor.name}</div>
            <div class="text-green-200 text-sm">${doctor.specialization}</div>
            <div class="text-green-300 text-xs mt-1">${doctor.nursesCount} nurse(s)</div>
          </div>
          <button type="button" 
                  data-action="click->dragdrop-room-edit#removeDoctor"
                  data-doctor-id="${doctor.id}"
                  class="text-red-300 hover:text-red-100 text-sm ml-2 px-2 py-1 rounded hover:bg-red-900/50 transition-colors"
                  title="Remove doctor">
            ✕
          </button>
        </div>
      </div>
    `).join('')
  }

  renderAssignedNurses() {
    if (!this.hasAssignedNursesTarget) return

    if (this.assignedNurseIds.length === 0) {
      this.assignedNursesTarget.innerHTML = `
        <div class="text-center text-gray-500 py-8 border-2 border-dashed border-gray-600 h-full flex flex-col items-center justify-center rounded-lg">
          <div class="text-sm">Drop nurses here</div>
          <div class="text-xs mt-1">Drag nurses from the left to assign them</div>
        </div>
      `
      return
    }

    // Get nurse data from the available nurses list or cache
    const nurseCards = []
    this.assignedNurseIds.forEach(nurseId => {
      const originalCard = this.nursesListTarget.querySelector(`[data-nurse-id="${nurseId}"]`)
      if (originalCard) {
        nurseCards.push({
          id: nurseId,
          name: originalCard.dataset.nurseName,
          specialization: originalCard.dataset.nurseSpecialization,
          doctor: originalCard.dataset.nurseDoctor
        })
      } else if (this.nurseDataCache && this.nurseDataCache[nurseId]) {
        // Use cached data if original card is not available
        nurseCards.push(this.nurseDataCache[nurseId])
      }
    })

    this.assignedNursesTarget.innerHTML = nurseCards.map(nurse => `
      <div class="nurse-card bg-blue-700 p-3 mb-3 rounded-lg border border-blue-500"
           data-nurse-id="${nurse.id}">
        <div class="flex justify-between items-start">
          <div class="flex-1">
            <div class="text-white font-medium">${nurse.name}</div>
            <div class="text-blue-200 text-sm">${nurse.specialization}</div>
            <div class="text-blue-300 text-xs mt-1">Doctor: ${nurse.doctor}</div>
          </div>
          <button type="button" 
                  data-action="click->dragdrop-room-edit#removeNurse"
                  data-nurse-id="${nurse.id}"
                  class="text-red-300 hover:text-red-100 text-sm ml-2 px-2 py-1 rounded hover:bg-red-900/50 transition-colors"
                  title="Remove nurse">
            ✕
          </button>
        </div>
      </div>
    `).join('')
  }

  renderAssignedDoctor(originalCard, doctorId) {
    // This method is called when a doctor is dropped, but we re-render all assigned doctors
    // So we just need to trigger the full re-render
    this.renderAssignedDoctors()
  }

  renderAssignedNurse(originalCard, nurseId) {
    // This method is called when a nurse is dropped, but we re-render all assigned nurses
    // So we just need to trigger the full re-render
    this.renderAssignedNurses()
  }

  removeDoctor(event) {
    event.preventDefault()
    event.stopPropagation()

    const doctorId = event.target.dataset.doctorId
    console.log('Removing doctor with ID:', doctorId)
    console.log('Current assigned doctor IDs:', this.assignedDoctorIds)

    this.assignedDoctorIds = this.assignedDoctorIds.filter(id => id !== doctorId)
    console.log('New assigned doctor IDs:', this.assignedDoctorIds)

    this.renderAssignedDoctors()
    this.updateHiddenFields()
  }

  removeNurse(event) {
    event.preventDefault()
    event.stopPropagation()

    const nurseId = event.target.dataset.nurseId
    console.log('Removing nurse with ID:', nurseId)
    console.log('Current assigned nurse IDs:', this.assignedNurseIds)

    this.assignedNurseIds = this.assignedNurseIds.filter(id => id !== nurseId)
    console.log('New assigned nurse IDs:', this.assignedNurseIds)

    this.renderAssignedNurses()
    this.updateHiddenFields()
  }

  updateHiddenFields() {
    if (!this.hasHiddenFieldsTarget) return

    // Clear existing hidden fields
    this.hiddenFieldsTarget.innerHTML = ''

    // Add doctor hidden fields
    this.assignedDoctorIds.forEach((doctorId, index) => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'room[doctor_ids][]'
      input.value = doctorId
      this.hiddenFieldsTarget.appendChild(input)
    })

    // Add nurse hidden fields
    this.assignedNurseIds.forEach((nurseId, index) => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'room[nurse_ids][]'
      input.value = nurseId
      this.hiddenFieldsTarget.appendChild(input)
    })
  }

  filterDoctors() {
    if (!this.hasDoctorSearchTarget) return

    const searchTerm = this.doctorSearchTarget.value.toLowerCase()
    const doctorCards = this.doctorsListTarget.querySelectorAll('.doctor-card')

    doctorCards.forEach(card => {
      const name = card.dataset.doctorName.toLowerCase()
      const specialization = card.dataset.doctorSpecialization.toLowerCase()

      if (name.includes(searchTerm) || specialization.includes(searchTerm)) {
        card.style.display = ''
      } else {
        card.style.display = 'none'
      }
    })
  }

  filterNurses() {
    if (!this.hasNurseSearchTarget) return

    const searchTerm = this.nurseSearchTarget.value.toLowerCase()
    const nurseCards = this.nursesListTarget.querySelectorAll('.nurse-card')

    nurseCards.forEach(card => {
      const name = card.dataset.nurseName.toLowerCase()
      const specialization = card.dataset.nurseSpecialization.toLowerCase()
      const doctor = card.dataset.nurseDoctor.toLowerCase()

      if (name.includes(searchTerm) || specialization.includes(searchTerm) || doctor.includes(searchTerm)) {
        card.style.display = ''
      } else {
        card.style.display = 'none'
      }
    })
  }
}
