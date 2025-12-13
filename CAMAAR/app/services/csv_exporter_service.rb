class CsvExporterService
  require 'csv'

  def initialize(admin, course_code)
    @admin = admin
    @course_code = course_code
  end

  def call
    return error_result("Admin não encontrado") unless @admin
    return error_result("Código do curso não fornecido") if @course_code.blank?

    forms = find_admin_forms
    return error_result("Você não tem permissão para acessar esta turma") if forms.empty?

    {
      success: true,
      csv_data: generate_csv(forms),
      filename: generate_filename
    }
  end

  private

  def find_admin_forms
    @admin.forms
          .joins(:course)
          .where(courses: { code: @course_code })
          .includes(:course, :question_set, answers: :form)
  end

  def generate_csv(forms)
    question_set = forms.first.question_set
    questions = question_set.data
    answers = Answer.where(form_id: forms.pluck(:id))
                    .includes(form: [:course, :question_set])

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
    # Use CSV parser instead of simple split to handle commas in answers
    CSV.parse_line(data) || []
  rescue CSV::MalformedCSVError
    # Fallback for legacy data
    data.split(',')
  end

  def generate_filename
    "#{@course_code}_performance_#{Date.today.strftime('%Y%m%d')}.csv"
  end

  def error_result(message)
    {
      success: false,
      error: message
    }
  end
end
