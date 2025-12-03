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

  toggleOptions(event) {
    const select = event.target
    const questionItem = select.closest('.question-item')
    const optionsSection = questionItem.querySelector('.question-options')
    const optionsList = optionsSection.querySelector('.options-list')

    if (select.value === 'radio') {
      optionsSection.style.display = 'block'

      // If no options exist, add 2 default options
      if (optionsList.children.length === 0) {
        this.addOptionToList(optionsList)
        this.addOptionToList(optionsList)
      }
    } else {
      optionsSection.style.display = 'none'
    }
  }

  addOption(event) {
    event.preventDefault()
    const button = event.currentTarget
    const questionOptions = button.closest('.question-options')
    const optionsList = questionOptions.querySelector('.options-list')
    this.addOptionToList(optionsList)
  }

  addOptionToList(optionsList) {
    const optionTemplate = document.getElementById('option-template')
    if (!optionTemplate) {
      console.error('Option template not found')
      return
    }

    const clone = optionTemplate.content.cloneNode(true)
    optionsList.appendChild(clone)
  }

  removeOption(event) {
    event.preventDefault()
    const optionItem = event.currentTarget.closest('.option-item')
    const optionsList = optionItem.parentElement

    // Only remove if there's more than one option
    if (optionsList.children.length > 1) {
      optionItem.remove()
    } else {
      alert('Você deve ter pelo menos uma opção')
    }
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
        const questionData = {
          question: input.value,
          type: typeSelect ? typeSelect.value : "text"
        }

        // If radio type, collect options
        if (questionData.type === 'radio') {
          const options = []
          const optionInputs = item.querySelectorAll('.option-input')

          optionInputs.forEach(optionInput => {
            if (optionInput.value.trim()) {
              options.push(optionInput.value)
            }
          })

          questionData.options = options
        }

        questions.push(questionData)
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
