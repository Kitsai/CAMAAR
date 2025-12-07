class FormsController < ApplicationController
  before_action :require_login
  before_action :find_form, only: [:show, :submit]
  before_action :verify_form_access, only: [:show, :submit]

  def index
    # For users: show forms they need to respond to
    @forms = current_user.forms.includes(:course, :question_set)
  end

  def results
    # For admins: show forms they have created
    unless current_user.admin?
      redirect_to avaliacoes_path, alert: "Acesso negado"
      return
    end
    
    @forms = current_user.admin.forms.includes(:course, :question_set)
  end

  def export_csv
    require 'csv'
    
    unless current_user.admin?
      redirect_to avaliacoes_path, alert: "Acesso negado"
      return
    end

    course_code = params[:course_code]
    
    # Find all forms created by this admin for the specified course
    admin_forms = current_user.admin.forms.joins(:course).where(courses: { code: course_code })
    
    if admin_forms.empty?
      redirect_to forms_path, alert: "Você não tem permissão para acessar esta turma"
      return
    end

    # Collect all answers for these forms
    form_ids = admin_forms.pluck(:id)
    answers = Answer.includes(form: [:course, :question_set]).where(form_id: form_ids)

    # Get the question set (assume all forms for same course use same questions)
    question_set = admin_forms.first.question_set
    questions = question_set.data

    # Generate CSV
    csv_string = CSV.generate do |csv|
      # Header row
      header = ["Formulário", "Turma", "Semestre"]
      questions.each_with_index do |q, idx|
        header << "Questão #{idx + 1}"
        header << "Resposta #{idx + 1}"
      end
      csv << header

      # Data rows
      answers.each do |answer|
        row = [
          "Form #{answer.form.id}",
          answer.form.course.code,
          answer.form.course.semester
        ]
        
        # Parse CSV data (answers are stored as comma-separated values)
        answer_values = answer.data.split(',')
        
        questions.each_with_index do |question, idx|
          row << question["text"]
          row << (answer_values[idx] || "")
        end
        
        csv << row
      end
    end

    # Send the CSV file
    send_data csv_string,
              filename: "#{course_code}_performance_#{Date.today.strftime('%Y%m%d')}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end

  def show
    # Display the form for the user to answer
    @questions = @form.question_set.data
  end

  def submit
    # Validate all questions are answered
    # Handle both array format (from specs) and hash format (from form view)
    answers_param = params[:answers]
    expected_count = @form.question_set.data.size
    
    if answers_param.is_a?(Array)
      # Array format from specs - validate each has a question and answer
      if answers_param.size != expected_count || answers_param.any? { |a| a[:answer].blank? || a["answer"].blank? }
        redirect_to form_path(@form), alert: "Por favor, responda todas as questões obrigatórias"
        return
      end
      answers_array = answers_param
    else
      # Hash format from form view - convert to array
      answers_data = answers_param&.to_unsafe_h || {}
      
      # Check that we have the right number of answers and all have non-blank answer values
      if answers_data.keys.size != expected_count || answers_data.values.any? { |v| v["answer"].blank? }
        redirect_to form_path(@form), alert: "Por favor, responda todas as questões obrigatórias"
        return
      end
      
      answers_array = answers_data.values
    end

    # Create the answer - store only answers as CSV format
    csv_data = answers_array.map do |answer_data|
      answer_data[:answer] || answer_data["answer"]
    end.join(",")
    
    Answer.create!(
      form: @form,
      data: csv_data
    )

    # Remove the form_request (mark as submitted)
    FormRequest.where(user: current_user, form: @form).destroy_all

    redirect_to avaliacoes_path, notice: "Avaliação enviada com sucesso!"
  end

  private

  def find_form
    @form = Form.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to avaliacoes_path, alert: "Formulário não encontrado"
  end

  def verify_form_access
    # Admins can access forms they created
    # Regular users can only access forms they have a FormRequest for
    if current_user.admin?
      unless @form.admin_id == current_user.admin.user_id
        redirect_to avaliacoes_path, alert: "Você não tem permissão para acessar este formulário"
      end
    else
      unless FormRequest.exists?(user: current_user, form: @form)
        redirect_to avaliacoes_path, alert: "Este formulário não está mais disponível para você"
      end
    end
  end
end
