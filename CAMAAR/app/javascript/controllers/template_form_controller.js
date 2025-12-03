import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["questions", "questionsContainer", "questionItem"]

  connect() {
    // Update button state on load
    this.updateSubmitButtonState()
  }

  addQuestion(event) {
    if (event) {
      event.preventDefault()
    }

    const template = document.getElementById('question-template')
    if (!template) {
      console.error('Question template not found')
      return
    }

    const clone = template.content.cloneNode(true)

    // Append the new empty question to the questions container
    this.questionsTarget.appendChild(clone)

    // Update submit button state
    this.updateSubmitButtonState()
  }

  removeQuestion(event) {
    event.preventDefault()
    const questionItem = event.currentTarget.closest('.question-item')

    // Remove the question (no minimum requirement)
    questionItem.remove()

    // Update submit button state
    this.updateSubmitButtonState()
  }

  submit(event) {
    // Collect questions data
    const questions = []
    const questionItems = this.element.querySelectorAll('.question-item')

    questionItems.forEach(item => {
      const input = item.querySelector('.question-input')
      const typeSelect = item.querySelector('.question-type-select')

      if (input && input.value.trim()) {
        questions.push({
          question: input.value,
          type: typeSelect ? typeSelect.value : "text"
        })
      }
    })

    // Add questions data as JSON to a hidden field
    const form = event.target
    let questionsField = form.querySelector('input[name="template[question_set_attributes][data]"]')

    if (!questionsField) {
      questionsField = document.createElement('input')
      questionsField.type = 'hidden'
      questionsField.name = 'template[question_set_attributes][data]'
      form.appendChild(questionsField)
    }

    questionsField.value = JSON.stringify(questions)
  }

  updateSubmitButtonState() {
    const submitButton = this.element.querySelector('.btn-submit')
    if (!submitButton) return

    const questionCount = this.questionsTarget.querySelectorAll('.question-item').length

    if (questionCount === 0) {
      submitButton.disabled = true
      submitButton.style.opacity = '0.5'
      submitButton.style.cursor = 'not-allowed'
    } else {
      submitButton.disabled = false
      submitButton.style.opacity = '1'
      submitButton.style.cursor = 'pointer'
    }
  }
}
