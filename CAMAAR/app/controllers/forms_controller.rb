class FormsController < ApplicationController
  include AdminAuthorizable

  before_action :require_login
  before_action :find_form, only: [ :show, :submit ]
  before_action :verify_form_access, only: [ :show, :submit ]
  before_action :require_admin, only: [ :results, :export_csv ]

  # Lista formulários disponíveis para o usuário responder
  # Mostra apenas formulários com FormRequest ativo
  def index
    # For users: show forms they need to respond to
    @forms = current_user.forms.includes(:course, :question_set)
  end

  # Cria formulários para turmas selecionadas a partir de um template
  # Gera FormRequests para alunos e professores das turmas
  def create
    CreateFormService.call(
      admin: current_user.admin,
      template_id: params[:template_id],
      course_ids: params[:course_ids]
    )

    redirect_to forms_path, notice: "Formulários criados com sucesso!"

  rescue CreateFormService::MissingTemplate
    redirect_to forms_path, alert: "É necessário selecionar um template"

  rescue CreateFormService::MissingCourses
    redirect_to forms_path, alert: "É necessário selecionar pelo menos uma turma"
  end

  # Lista formulários criados pelo admin (área de gerenciamento)
  def results
    # For admins: show forms they have created, ordered by creation date
    @forms = current_admin.forms.includes(:course, :question_set).order(created_at: :desc)
  end

  # Exporta respostas de uma turma em formato CSV
  # Usa CsvExporterService para gerar o arquivo
  def export_csv
    result = CsvExporterService.new(current_admin, params[:form_id]).call

    if result[:success]
      send_data result[:csv_data],
                filename: result[:filename],
                type: "text/csv",
                disposition: "attachment"
    else
      redirect_to forms_path, alert: result[:error]
    end
  end

  # Exibe um formulário para o usuário responder
  def show
    # Display the form for the user to answer
    @questions = @form.question_set.data
  end

  # Submete as respostas de um formulário
  # Usa AnswerStorageService para armazenar em formato CSV
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

  # Busca o formulário pelo ID do parâmetro
  def find_form
    @form = Form.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to avaliacoes_path, alert: "Formulário não encontrado"
  end

  # Verifica se o usuário tem permissão para acessar o formulário
  # Admins: podem acessar formulários que criaram
  # Usuários: podem acessar apenas formulários com FormRequest ativo
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
