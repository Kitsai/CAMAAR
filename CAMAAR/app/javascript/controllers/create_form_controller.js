import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "list"]

  add() {
    const option = this.selectTarget.selectedOptions[0]
    if (!option || !option.value) return

    const templateId = option.value

    // Prevent duplicate rows
    if (this.listTarget.querySelector(`[data-template-id="${templateId}"]`)) {
      this.selectTarget.value = ""
      return
    }

    const name = option.dataset.name
    const semester = option.dataset.semester
    const code = option.dataset.code || "N/A"

    const item = document.createElement("div")
    item.classList.add("info-item")
    item.dataset.templateId = templateId
    item.innerHTML = `
      <input type="checkbox" class="green-checkbox">

      <div class="info-item-content">
        <div class="item-content">
          <span>${name}</span>

          <div class="spacer">
            <span>${semester}</span>
            <span>${code}</span>
          </div>
        </div>
        <div class="divider"></div>
      </div>
    `

    this.listTarget.appendChild(item)

    this.selectTarget.value = ""
  }
}