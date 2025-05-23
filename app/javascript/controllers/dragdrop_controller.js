import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="dragdrop"
export default class extends Controller {
  static targets = ["doctorsList", "selectedDoctor", "hiddenField", "nursesInfo", "searchInput", "nursesFilterBtn", "noResults", "doctorsCount", "nurseSelector"]
  static values = {
    currentDoctorId: String,
    currentDoctorName: String,
    currentNurseId: String,
    currentNurseName: String,
    showOnlyWithNurses: Boolean
  }

  connect() {
    this.showOnlyWithNursesValue = false
    this.initializeSortable()
    this.updateSelectedDoctor()
  }

  initializeSortable() {
    // Make doctors list sortable (draggable)
    if (this.hasDoctorsListTarget) {
      this.sortable = Sortable.create(this.doctorsListTarget, {
        group: {
          name: "doctors",
          pull: "clone",
          put: false
        },
        animation: 150,
        sort: false, // Disable sorting in the source list
        onEnd: (evt) => {
          // Remove the cloned item from source list
          if (evt.clone) {
            evt.clone.remove()
          }
        }
      })
    }

    // Make selected doctor area sortable (droppable)
    if (this.hasSelectedDoctorTarget) {
      this.selectedSortable = Sortable.create(this.selectedDoctorTarget, {
        group: "doctors",
        animation: 150,
        onAdd: (evt) => {
          // When a doctor is dropped
          const doctorCard = evt.item
          const doctorId = doctorCard.dataset.doctorId
          const doctorName = doctorCard.dataset.doctorName

          // Clear any existing doctor
          this.clearSelectedDoctor()

          // Update the hidden form field
          this.updateHiddenField(doctorId)

          // Update the display and fetch nurses
          this.showSelectedDoctor(doctorId, doctorName, doctorCard)
          this.fetchNursesForNewDoctor(doctorId)
        },
        onRemove: (evt) => {
          // When a doctor is removed
          this.clearSelectedDoctor()
          this.updateHiddenField("")
          this.updateHiddenNurseField("")
          this.clearNurses()

          // Reset current values
          this.currentDoctorIdValue = ""
          this.currentDoctorNameValue = ""
          this.currentNurseIdValue = ""
          this.currentNurseNameValue = ""
        }
      })
    }
  }

  updateSelectedDoctor() {
    if (this.currentDoctorIdValue && this.currentDoctorNameValue) {
      this.showCurrentDoctor()
      this.fetchAndShowNurses(this.currentDoctorIdValue)
    } else {
      this.clearSelectedDoctor()
    }
  }

  showCurrentDoctor() {
    const currentDoctorHtml = `
      <div class="doctor-card bg-indigo-600 p-4 rounded-lg border-2 border-dashed border-indigo-400" 
           data-doctor-id="${this.currentDoctorIdValue}">
        <div class="text-white font-semibold">${this.currentDoctorNameValue}</div>
        <div class="text-indigo-200 text-sm mt-1">Currently Assigned</div>
        <button type="button" class="mt-2 text-red-300 hover:text-red-100 text-sm" 
                data-action="click->dragdrop#removeDoctor">
          Remove
        </button>
      </div>
    `
    this.selectedDoctorTarget.innerHTML = currentDoctorHtml
    this.updateHiddenField(this.currentDoctorIdValue)
  }

  showSelectedDoctor(doctorId, doctorName, originalCard) {
    const specialization = originalCard.querySelector('.text-gray-400').textContent

    const selectedDoctorHtml = `
      <div class="doctor-card bg-green-600 p-4 rounded-lg border-2 border-dashed border-green-400" 
           data-doctor-id="${doctorId}">
        <div class="text-white font-semibold">${doctorName}</div>
        <div class="text-green-200 text-sm">${specialization}</div>
        <div class="text-green-100 text-sm mt-1">Newly Assigned</div>
        <button type="button" class="mt-2 text-red-300 hover:text-red-100 text-sm" 
                data-action="click->dragdrop#removeDoctor">
          Remove
        </button>
      </div>
    `
    this.selectedDoctorTarget.innerHTML = selectedDoctorHtml

    // Reset current nurse values when a new doctor is assigned
    this.currentNurseIdValue = ""
    this.currentNurseNameValue = ""
  }

  clearSelectedDoctor() {
    this.selectedDoctorTarget.innerHTML = `
      <div class="w-full border-2 border-dashed border-gray-600 p-8 rounded-lg text-center">
        <div class="text-gray-400 text-lg mb-2">Drop Doctor Here</div>
        <div class="text-gray-500 text-sm">Drag a doctor from the list above to assign them to this room</div>
      </div>
    `
  }

  updateHiddenField(doctorId) {
    if (this.hasHiddenFieldTarget) {
      this.hiddenFieldTarget.value = doctorId
    }
  }

  removeDoctor(event) {
    event.preventDefault()
    this.clearSelectedDoctor()
    this.updateHiddenField("")
    this.updateHiddenNurseField("")
    this.clearNurses()

    // Reset current values
    this.currentDoctorIdValue = ""
    this.currentDoctorNameValue = ""
    this.currentNurseIdValue = ""
    this.currentNurseNameValue = ""
  }

  async fetchAndShowNurses(doctorId) {
    try {
      const response = await fetch(`/api/doctors/${doctorId}/nurses`)
      if (response.ok) {
        const data = await response.json()

        // If there's a current nurse assigned to the room, show it
        if (this.currentNurseIdValue && this.currentNurseNameValue) {
          this.showSelectedNurse(this.currentNurseIdValue, this.currentNurseNameValue)
          this.updateHiddenNurseField(this.currentNurseIdValue)
        } else {
          this.showNurses(data.nurses)
        }
      } else {
        console.error('Failed to fetch nurses')
        this.showNurses([])
      }
    } catch (error) {
      console.error('Error fetching nurses:', error)
      this.showNurses([])
    }
  }

  async fetchNursesForNewDoctor(doctorId) {
    try {
      const response = await fetch(`/api/doctors/${doctorId}/nurses`)
      if (response.ok) {
        const data = await response.json()
        this.showNurses(data.nurses)
      } else {
        console.error('Failed to fetch nurses')
        this.showNurses([])
      }
    } catch (error) {
      console.error('Error fetching nurses:', error)
      this.showNurses([])
    }
  }

  showNurses(nurses) {
    if (!this.hasNursesInfoTarget) return

    if (nurses.length === 0) {
      this.showNurseSelector()
      return
    }

    const nursesHtml = nurses.map(nurse => `
      <div class="flex items-center justify-between p-2 bg-gray-700 rounded">
        <div>
          <div class="text-white text-sm font-medium">${nurse.name}</div>
          <div class="text-gray-400 text-xs">${nurse.specialization}</div>
        </div>
        <div class="flex items-center gap-2">
          <div class="text-pink-300 text-xs">${nurse.gender}</div>
          <button type="button" 
                  data-action="click->dragdrop#selectThisNurse"
                  data-nurse-id="${nurse.id}"
                  data-nurse-name="${nurse.name} - ${nurse.specialization}"
                  class="px-2 py-1 text-xs bg-indigo-600 text-white rounded hover:bg-indigo-700 transition">
            Select
          </button>
        </div>
      </div>
    `).join('')

    this.nursesInfoTarget.innerHTML = `
      <div class="mt-4 p-3 bg-gray-800 border border-gray-600 rounded-lg">
        <h5 class="text-sm font-medium text-gray-300 mb-3">Nurses under this Doctor (${nurses.length})</h5>
        <p class="text-gray-400 text-xs mb-3">Click "Select" to assign a nurse to this room:</p>
        <div class="space-y-2">
          ${nursesHtml}
        </div>
      </div>
    `
  }

  selectThisNurse(event) {
    const nurseId = event.target.dataset.nurseId
    const nurseName = event.target.dataset.nurseName

    this.updateHiddenNurseField(nurseId)
    this.showSelectedNurse(nurseId, nurseName)
  }

  clearNurses() {
    if (this.hasNursesInfoTarget) {
      this.nursesInfoTarget.innerHTML = ''
    }
  }

  async showNurseSelector() {
    try {
      const response = await fetch('/api/nurses/available')
      if (response.ok) {
        const data = await response.json()
        this.renderNurseSelector(data.nurses)
      } else {
        console.error('Failed to fetch available nurses')
        this.renderNurseSelector([])
      }
    } catch (error) {
      console.error('Error fetching nurses:', error)
      this.renderNurseSelector([])
    }
  }

  renderNurseSelector(nurses) {
    if (nurses.length === 0) {
      this.nursesInfoTarget.innerHTML = `
        <div class="mt-4 p-3 bg-gray-800 border border-gray-600 rounded-lg">
          <h5 class="text-sm font-medium text-gray-300 mb-2">No Nurses Available</h5>
          <p class="text-gray-500 text-sm">This doctor has no assigned nurses and there are no available nurses to select.</p>
        </div>
      `
      return
    }

    const nurseOptions = nurses.map(nurse =>
      `<option value="${nurse.id}">${nurse.name} - ${nurse.specialization}</option>`
    ).join('')

    this.nursesInfoTarget.innerHTML = `
      <div class="mt-4 p-3 bg-gray-800 border border-gray-600 rounded-lg">
        <h5 class="text-sm font-medium text-gray-300 mb-3">Select a Nurse</h5>
        <p class="text-gray-400 text-xs mb-3">This doctor has no assigned nurses. Please select one:</p>
        <div class="flex gap-2">
          <select data-dragdrop-target="nurseSelector" 
                  class="flex-1 px-3 py-2 text-sm bg-gray-700 border border-gray-500 rounded text-white focus:ring-indigo-400 focus:border-indigo-400">
            <option value="">-- Select a Nurse --</option>
            ${nurseOptions}
          </select>
          <button type="button" 
                  data-action="click->dragdrop#assignSelectedNurse"
                  class="px-4 py-2 text-sm bg-indigo-600 text-white rounded hover:bg-indigo-700 transition">
            Assign
          </button>
        </div>
      </div>
    `
  }

  assignSelectedNurse() {
    if (!this.hasNurseSelectorTarget) return

    const selectedNurseId = this.nurseSelectorTarget.value
    if (!selectedNurseId) {
      alert('Please select a nurse first')
      return
    }

    // Update the hidden nurse field in the form
    this.updateHiddenNurseField(selectedNurseId)

    // Get the selected nurse name for display
    const selectedOption = this.nurseSelectorTarget.options[this.nurseSelectorTarget.selectedIndex]
    const nurseName = selectedOption.text

    // Show confirmation
    this.showSelectedNurse(selectedNurseId, nurseName)
  }

  updateHiddenNurseField(nurseId) {
    // Find or create a hidden nurse_id field
    let nurseField = document.querySelector('input[name="room[nurse_id]"]')
    if (!nurseField) {
      nurseField = document.createElement('input')
      nurseField.type = 'hidden'
      nurseField.name = 'room[nurse_id]'
      this.hiddenFieldTarget.parentNode.appendChild(nurseField)
    }
    nurseField.value = nurseId
  }

  showSelectedNurse(nurseId, nurseName) {
    this.nursesInfoTarget.innerHTML = `
      <div class="mt-4 p-3 bg-green-800 border border-green-600 rounded-lg">
        <h5 class="text-sm font-medium text-green-200 mb-2">Selected Nurse</h5>
        <div class="flex items-center justify-between">
          <div class="text-green-100 text-sm font-medium">${nurseName}</div>
          <button type="button" 
                  data-action="click->dragdrop#removeSelectedNurse"
                  class="text-red-300 hover:text-red-100 text-xs">
            Remove
          </button>
        </div>
      </div>
    `
  }

  async removeSelectedNurse() {
    this.updateHiddenNurseField('')

    // If there's a current doctor assigned, check if they have nurses
    if (this.currentDoctorIdValue) {
      await this.fetchAndShowNursesAfterRemoval(this.currentDoctorIdValue)
    } else {
      this.showNurseSelector()
    }
  }

  async fetchAndShowNursesAfterRemoval(doctorId) {
    try {
      const response = await fetch(`/api/doctors/${doctorId}/nurses`)
      if (response.ok) {
        const data = await response.json()
        if (data.nurses.length > 0) {
          // Show doctor's nurses for selection
          this.showDoctorNursesSelector(data.nurses)
        } else {
          // No nurses under this doctor, show general nurse selector
          this.showNurseSelector()
        }
      } else {
        console.error('Failed to fetch nurses')
        this.showNurseSelector()
      }
    } catch (error) {
      console.error('Error fetching nurses:', error)
      this.showNurseSelector()
    }
  }

  showDoctorNursesSelector(nurses) {
    const nurseOptions = nurses.map(nurse =>
      `<option value="${nurse.id}">${nurse.name} - ${nurse.specialization}</option>`
    ).join('')

    this.nursesInfoTarget.innerHTML = `
      <div class="mt-4 p-3 bg-blue-800 border border-blue-600 rounded-lg">
        <h5 class="text-sm font-medium text-blue-200 mb-3">Choose from Doctor's Nurses</h5>
        <p class="text-blue-300 text-xs mb-3">Select a nurse from the assigned doctor's team:</p>
        <div class="flex gap-2">
          <select data-dragdrop-target="nurseSelector" 
                  class="flex-1 px-3 py-2 text-sm bg-blue-700 border border-blue-500 rounded text-white focus:ring-blue-400 focus:border-blue-400">
            <option value="">-- Select a Nurse --</option>
            ${nurseOptions}
          </select>
          <button type="button" 
                  data-action="click->dragdrop#assignSelectedNurse"
                  class="px-4 py-2 text-sm bg-blue-600 text-white rounded hover:bg-blue-700 transition">
            Assign
          </button>
        </div>
        <div class="mt-2">
          <button type="button" 
                  data-action="click->dragdrop#showAllNurses"
                  class="text-blue-300 hover:text-blue-100 text-xs underline">
            Or choose from all available nurses
          </button>
        </div>
      </div>
    `
  }

  showAllNurses() {
    this.showNurseSelector()
  }

  // Filter functionality
  filterDoctors() {
    const searchTerm = this.hasSearchInputTarget ? this.searchInputTarget.value.toLowerCase() : ''
    const doctorCards = this.doctorsListTarget.querySelectorAll('.doctor-card')
    let visibleCount = 0

    doctorCards.forEach(card => {
      const doctorName = card.dataset.doctorName.toLowerCase()
      const specialization = card.dataset.doctorSpecialization.toLowerCase()
      const nursesCount = parseInt(card.dataset.nursesCount)

      const matchesSearch = doctorName.includes(searchTerm) || specialization.includes(searchTerm)
      const matchesNursesFilter = !this.showOnlyWithNursesValue || nursesCount > 0

      if (matchesSearch && matchesNursesFilter) {
        card.style.display = ''
        visibleCount++
      } else {
        card.style.display = 'none'
      }
    })

    // Show/hide no results message and update count
    if (this.hasNoResultsTarget) {
      if (visibleCount === 0) {
        this.noResultsTarget.classList.remove('hidden')
      } else {
        this.noResultsTarget.classList.add('hidden')
      }
    }

    // Update doctors count
    if (this.hasDoctorsCountTarget) {
      const totalCount = doctorCards.length
      this.doctorsCountTarget.textContent = `(${visibleCount}/${totalCount})`
    }
  }

  toggleNursesFilter() {
    this.showOnlyWithNursesValue = !this.showOnlyWithNursesValue

    if (this.hasNursesFilterBtnTarget) {
      if (this.showOnlyWithNursesValue) {
        this.nursesFilterBtnTarget.textContent = 'Show All'
        this.nursesFilterBtnTarget.classList.remove('bg-purple-600', 'hover:bg-purple-700')
        this.nursesFilterBtnTarget.classList.add('bg-green-600', 'hover:bg-green-700')
      } else {
        this.nursesFilterBtnTarget.textContent = 'Show with Nurses'
        this.nursesFilterBtnTarget.classList.remove('bg-green-600', 'hover:bg-green-700')
        this.nursesFilterBtnTarget.classList.add('bg-purple-600', 'hover:bg-purple-700')
      }
    }

    this.filterDoctors()
  }

  clearFilters() {
    this.showOnlyWithNursesValue = false

    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ''
    }

    if (this.hasNursesFilterBtnTarget) {
      this.nursesFilterBtnTarget.textContent = 'Show with Nurses'
      this.nursesFilterBtnTarget.classList.remove('bg-green-600', 'hover:bg-green-700')
      this.nursesFilterBtnTarget.classList.add('bg-purple-600', 'hover:bg-purple-700')
    }

    this.filterDoctors()
  }
}