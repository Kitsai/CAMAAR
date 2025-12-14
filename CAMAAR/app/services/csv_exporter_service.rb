class CsvExporterService
  require 'csv'

  def initialize(admin, form_id)
    @admin = admin
    @form_id = form_id
  end

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

  def build_header(questions)
    header = ["Formulário", "Turma", "Semestre"]
    questions.each_with_index do |question, idx|
      header << "Questão #{idx + 1}"
      header << "Resposta #{idx + 1}"
    end
    header
  end

  def build_row(answer, questions)
    row = [
      "Form #{answer.form.id}",
      answer.form.course.code,
      answer.form.course.semester
    ]
    
    answer_values = parse_answer_data(answer.data)
    
    questions.each_with_index do |question, idx|
      row << question["text"]
      row << (answer_values[idx] || "")
    end
    
    row
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

  def error_result(message)
    {
      success: false,
      error: message
    }
  end
end
