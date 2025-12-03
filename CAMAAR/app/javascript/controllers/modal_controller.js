import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "modal"]
  static values = { open: Boolean }

  connect() {
    if (this.openValue) {
      this.open()
    }

    // Add escape key listener
    this.escapeHandler = this.closeOnEscape.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
  }

  disconnect() {
    document.removeEventListener('keydown', this.escapeHandler)
  }

  open(event) {
    document.body.style.overflow = 'hidden'
    const overlay = document.getElementById('modalOverlay')
    const modal = document.getElementById('modal')

    if (overlay && modal) {
      overlay.classList.add('active')
      modal.classList.add('active')
    }

    // Reset modal content if opening for create (not edit via turbo frame)
    if (event && event.currentTarget && !event.currentTarget.dataset.turboFrame) {
      this.resetModalContent()
    }
  }

  resetModalContent() {
    // Reset the form to create mode
    const modalTitle = document.querySelector('.modal-title')
    if (modalTitle) {
      modalTitle.textContent = 'Novo Template'
    }

    // Clear the template name input
    const nameInput = document.querySelector('input[name="template[name]"]')
    if (nameInput) {
      nameInput.value = ''
    }

    // Clear all questions
    const questionsContainer = document.querySelector('[data-template-form-target="questions"]')
    if (questionsContainer) {
      questionsContainer.innerHTML = ''
    }

    // Reset the form action to create (remove any id in the action URL)
    const form = document.querySelector('.template-form')
    if (form) {
      form.action = '/templates'
      form.querySelector('input[name="_method"]')?.remove()
    }

    // Change submit button text
    const submitButton = document.querySelector('.btn-submit')
    if (submitButton) {
      submitButton.value = 'Criar'
    }

    // Remove any hidden question_set id field
    const questionSetIdField = form?.querySelector('input[name="template[question_set_attributes][id]"]')
    if (questionSetIdField) {
      questionSetIdField.remove()
    }

    // Update submit button state (should be disabled with no questions)
    const templateFormController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller~="template-form"]'),
      'template-form'
    )
    if (templateFormController) {
      templateFormController.updateSubmitButtonState()
    }
  }

  close() {
    document.body.style.overflow = ''
    const overlay = document.getElementById('modalOverlay')
    const modal = document.getElementById('modal')

    if (overlay && modal) {
      overlay.classList.remove('active')
      modal.classList.remove('active')
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  closeOnOverlay(event) {
    // Only close if clicking directly on the overlay, not on modal content
    if (event.target.id === 'modalOverlay') {
      this.close()
    }
  }
}
