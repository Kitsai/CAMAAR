# Service responsável por exportar respostas de formulários em formato CSV
#
# Uso:
#   service = CsvExporterService.new(admin, course_code)
#   result = service.call
#
# Retorna:
#   { success: true, csv_data: String, filename: String } em caso de sucesso
#   { success: false, error: String } em caso de erro
#
# Características:
#   - Usa CSV.generate_line para escape correto de vírgulas e aspas
#   - Valida permissões do admin para acessar o curso
#   - Compatível com dados legados
class CsvExporterService
  require 'csv'

  def initialize(admin, form_id)
    @admin = admin
    @form_id = form_id
  end

  # Executa a exportação do CSV
  # Valida permissões e retorna os dados CSV ou erro
  def call
    return error_result("Admin não encontrado") unless @admin
    return error_result("ID do formulário não fornecido") if @form_id.blank?

    form = find_admin_form
    return error_result("Você não tem permissão para acessar este formulário") unless form

    {
      success: true,
      csv_data: generate_csv(form),
      filename: generate_filename(form)
    }
  end

  private

  def find_admin_form
    @admin.forms
          .includes(:course, :question_set, :answers)
          .find_by(id: @form_id)
  end

  def generate_csv(form)
    questions = form.question_set.data
    answers = form.answers.includes(form: [:course, :question_set])

    CSV.generate(headers: true) do |csv|
      csv << build_header(questions)

      answers.each do |answer|
        csv << build_row(answer, questions)
      end
    end
  end

  # Constrói a linha de cabeçalho do CSV
  def build_header(questions)
    questions.map { |question| question["text"] || question["question"] }
  end

  # Constrói uma linha de dados do CSV com as respostas
  def build_row(answer, questions)
    parse_answer_data(answer.data)
  end

  def parse_answer_data(data)
    # Usa parser CSV ao invés de split simples para lidar com vírgulas nas respostas
    CSV.parse_line(data) || []
  rescue CSV::MalformedCSVError
    # Fallback para dados legados
    data.split(',')
  end

  def generate_filename(form)
    "#{form.course.code}_form_#{form.id}_#{Date.today.strftime('%Y%m%d')}.csv"
  end

  # Retorna um hash de erro padronizado
  def error_result(message)
    {
      success: false,
      error: message
    }
  end
end
