class FormsController < ApplicationController
  include AdminAuthorizable
  
  before_action :require_login
  before_action :find_form, only: [:show, :submit]
  before_action :verify_form_access, only: [:show, :submit]
  before_action :require_admin, only: [:results, :export_csv]

  def index
    # For users: show forms they need to respond to
    @forms = current_user.forms.includes(:course, :question_set)
  end

  def create
    template_id = params[:template_id]
    course_ids  = (params[:course_ids] || []).reject(&:blank?)

    # Validate inputs before processing
    if template_id.blank?
      redirect_to forms_path, alert: "É necessário selecionar um template"
      return
    end

    if course_ids.empty?
      redirect_to forms_path, alert: "É necessário selecionar pelo menos uma turma"
      return
    end

    template = Template.find(template_id)

    ActiveRecord::Base.transaction do
      course_ids.each do |course_id|
        course = Course.find(course_id)

        form = Form.create!(
          admin: current_user.admin,
          course: course,
          question_set_id: template.question_set_id
        )

        # Create FormRequests for students + teacher
        recipients = course.students.to_a
        recipients << course.teacher if course.teacher.present?

        recipients.each do |user|
          FormRequest.find_or_create_by!(user: user, form: form)
        end
      end
    end

    redirect_to forms_path, notice: "Formulários criados com sucesso!"
  rescue ActiveRecord::RecordNotFound
    redirect_to forms_path, alert: "Template e curso inválidos"
  end

  def results
    # For admins: show forms they have created, ordered by creation date
    @forms = current_admin.forms.includes(:course, :question_set).order(created_at: :desc)
  end

  def export_csv
    result = CsvExporterService.new(current_admin, params[:form_id]).call

    if result[:success]
      send_data result[:csv_data],
                filename: result[:filename],
                type: 'text/csv',
                disposition: 'attachment'
    else
      redirect_to forms_path, alert: result[:error]
    end
  end

  def show
    # Display the form for the user to answer
    @questions = @form.question_set.data
  end

  def submit
    result = AnswerStorageService.new(@form, params[:answers]).call
    
    if result[:success]
      # Remove the form_request (mark as submitted)
      FormRequest.where(user: current_user, form: @form).destroy_all
      redirect_to avaliacoes_path, notice: "Avaliação enviada com sucesso!"
    else
      redirect_to form_path(@form), alert: result[:error]
    end
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
