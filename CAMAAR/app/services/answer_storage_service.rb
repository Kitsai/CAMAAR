class AnswerStorageService
  require 'csv'

  def initialize(form, answers_data)
    @form = form
    @answers_data = answers_data
  end

  def call
    return error_result("Formulário não encontrado") unless @form
    return error_result("Respostas não fornecidas") if @answers_data.blank?

    normalized_answers = normalize_answers(@answers_data)
    
    unless valid_answers?(normalized_answers)
      return error_result("Por favor, responda todas as questões obrigatórias")
    end

    answer = create_answer(normalized_answers)
    
    {
      success: true,
      answer: answer
    }
  end

  private

  def normalize_answers(answers_data)
    return answers_data if answers_data.is_a?(Array)
    
    # Convert hash format to array
    answers_hash = answers_data.to_unsafe_h
    answers_hash.values
  end

  def valid_answers?(answers)
    expected_count = @form.question_set.data.size
    
    return false unless answers.size == expected_count
    
    answers.none? do |answer_data|
      answer_value = answer_data[:answer] || answer_data["answer"]
      answer_value.blank?
    end
  end

  def create_answer(answers)
    csv_data = generate_csv_data(answers)
    
    Answer.create!(
      form: @form,
      data: csv_data
    )
  end

  def generate_csv_data(answers)
    answer_values = answers.map do |answer_data|
      answer_data[:answer] || answer_data["answer"]
    end
    
    # Use CSV generator to properly escape commas and quotes
    CSV.generate_line(answer_values).strip
  end

  def error_result(message)
    {
      success: false,
      error: message
    }
  end
end
