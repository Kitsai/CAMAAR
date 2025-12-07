class FormsController < ApplicationController
  before_action :require_login
  before_action :find_form, only: [:show, :submit]
  before_action :verify_form_access, only: [:show, :submit]

  def index
    # For admins: show forms they have created
    # For regular users: show forms they need to respond to
    if current_user.admin?
      @forms = current_user.admin.forms.includes(:course, :question_set)
    else
      @forms = current_user.forms.includes(:course, :question_set)
    end
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

    redirect_to forms_path, notice: "Avaliação enviada com sucesso!"
  end

  private

  def find_form
    @form = Form.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to forms_path, alert: "Formulário não encontrado"
  end

  def verify_form_access
    # Admins can access forms they created
    # Regular users can only access forms they have a FormRequest for
    if current_user.admin?
      unless @form.admin_id == current_user.admin.user_id
        redirect_to forms_path, alert: "Você não tem permissão para acessar este formulário"
      end
    else
      unless FormRequest.exists?(user: current_user, form: @form)
        redirect_to forms_path, alert: "Este formulário não está mais disponível para você"
      end
    end
  end
end
