# frozen_string_literal: true

# Form interaction helpers for Cucumber step definitions
# Provides reusable methods for complex form filling and question answering logic
module FormHelpers
  # Answers all questions in a form based on question_set data
  # Handles text and radio question types
  #
  # @param form [Form] The form object containing the question_set
  # @param answer_text_prefix [String] Prefix for text answers (default: "This is my answer to:")
  # @example
  #   answer_form_questions(@form)
  #   answer_form_questions(@form, answer_text_prefix: "My response:")
  def answer_form_questions(form, answer_text_prefix: "This is my answer to:")
    questions = form.question_set.data

    questions.each_with_index do |question, index|
      answer_question_by_type(question, index, answer_text_prefix)
    end
  end

  # Answers a single question based on its type
  #
  # @param question [Hash] The question hash with 'type' and 'question' keys
  # @param index [Integer] The index of the question in the form
  # @param answer_text_prefix [String] Prefix for text answers
  # @example
  #   answer_question_by_type(question, 0, "My answer:")
  def answer_question_by_type(question, index, answer_text_prefix)
    case question["type"]
    when "text"
      fill_in "answers[#{index}][answer]",
        with: "#{answer_text_prefix} #{question['question']}"
    when "radio"
      choose_first_radio_option(index, question["options"])
    end
  end

  # Selects first radio option if available
  #
  # @param index [Integer] The index of the question in the form
  # @param options [Array, nil] The array of radio options
  # @example
  #   choose_first_radio_option(0, ["Option 1", "Option 2"])
  def choose_first_radio_option(index, options)
    choose "answer_#{index}_0" if options&.any?
  end

  # Fills in standard form fields with provided data
  #
  # @param fields_hash [Hash] Hash mapping field labels to values
  # @example
  #   fill_form_fields('Email' => 'test@example.com', 'Name' => 'John')
  def fill_form_fields(fields_hash)
    fields_hash.each do |label, value|
      fill_in label, with: value
    end
  end

  # Selects from dropdown with waiting
  #
  # @param option_text [String] The option text to select
  # @param from [String] The select field ID or name
  # @param timeout [Integer] Maximum wait time in seconds (default: 3)
  # @example
  #   select_and_wait('Option 1', from: 'mySelect')
  def select_and_wait(option_text, from:, timeout: 3)
    expect(page).to have_select(from, visible: true, wait: timeout)
    select option_text, from: from
  end

  # Checks checkbox by value
  #
  # @param value [String, Integer] The value attribute of the checkbox
  # @example
  #   check_by_value('123')
  def check_by_value(value)
    find("input[type='checkbox'][value='#{value}']").check
  end
end

World(FormHelpers)
