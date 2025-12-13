import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "list"]

  connect() {
      this.element.addEventListener("turbo:submit-end", (event) => {
      if (event.detail.success) {
        this.resetModal()
      }
    })
  }

  toggleSelection(event) {
    const checkbox = event.currentTarget
    const hiddenInputs = checkbox.closest('.info-item').querySelectorAll('input[type="hidden"]')
    
    hiddenInputs.forEach(input => {
      input.disabled = !checkbox.checked
    })
  }

}