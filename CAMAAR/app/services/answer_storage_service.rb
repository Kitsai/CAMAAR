# Service responsável por armazenar respostas de formulários em formato CSV
#
# Uso:
#   service = AnswerStorageService.new(form, answers_data)
#   result = service.call
#
# Retorna:
#   { success: true, answer: Answer } em caso de sucesso
#   { success: false, error: String } em caso de erro
#
# Características:
#   - Valida que todas as questões foram respondidas
#   - Aceita dados em formato Array ou Hash
#   - Usa CSV.generate_line para escape correto de caracteres especiais
class AnswerStorageService
  require 'csv'

  def initialize(form, answers_data)
    @form = form
    @answers_data = answers_data
  end

  # Executa o armazenamento da resposta
  # Valida e normaliza os dados antes de criar o registro
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

  # Normaliza as respostas para formato de array
  # Aceita tanto array quanto hash como entrada
  def normalize_answers(answers_data)
    return answers_data if answers_data.is_a?(Array)
    
    # Converte formato hash para array
    answers_hash = answers_data.to_unsafe_h
    answers_hash.values
  end

  # Valida se todas as questões foram respondidas
  def valid_answers?(answers)
    expected_count = @form.question_set.data.size
    
    return false unless answers.size == expected_count
    
    answers.none? do |answer_data|
      answer_value = answer_data[:answer] || answer_data["answer"]
      answer_value.blank?
    end
  end

  # Cria o registro Answer com os dados em formato CSV
  def create_answer(answers)
    csv_data = generate_csv_data(answers)
    
    Answer.create!(
      form: @form,
      data: csv_data
    )
  end

  # Gera a string CSV com as respostas, escapando caracteres especiais
  def generate_csv_data(answers)
    answer_values = answers.map do |answer_data|
      answer_data[:answer] || answer_data["answer"]
    end
    
    # Usa gerador CSV para escapar corretamente vírgulas e aspas
    CSV.generate_line(answer_values).strip
  end

  # Retorna um hash de erro padronizado
  def error_result(message)
    {
      success: false,
      error: message
    }
  end
end
