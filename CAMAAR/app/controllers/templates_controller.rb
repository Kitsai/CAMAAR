# Controlador responsável por gerenciar templates de formulários.
#
# Este controlador permite que admins criem, visualizem, editem e excluam templates,
# que são usados como base para criar formulários de avaliação.
class TemplatesController < ApplicationController
  before_action :require_admin
  before_action :set_template, only: [ :show, :edit, :update, :destroy ]

  # Lista todos os templates do admin.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; renderiza a visualização 'index'.
  #
  # Efeitos colaterais: Carrega templates e inicializa um novo Template.
  def index
    @templates = current_admin.templates.includes(:question_set)
    @template = Template.new
    @template.build_question_set
  end

  # Renderiza o formulário para criar um novo template.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; renderiza a visualização 'new'.
  #
  # Efeitos colaterais: Inicializa um novo Template com QuestionSet.
  def new
    @template = Template.new
    @template.build_question_set
  end

  # Cria um novo template.
  #
  # Este método recebe argumentos dos parâmetros da requisição através de template_params.
  #
  # Este método não retorna valor; redireciona ou renderiza com base na validação.
  #
  # Efeitos colaterais: Cria um novo Template no banco de dados se válido.
  def create
    @template = current_admin.templates.build(template_params)

    if @template.save
      redirect_to templates_path, notice: "Template created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Exibe os detalhes de um template.
  #
  # Este método não recebe argumentos; usa @template definido por set_template.
  #
  # Este método não retorna valor; renderiza a visualização 'show'.
  #
  # Este método não possui efeitos colaterais.
  def show
  end

  # Renderiza o formulário para editar um template.
  #
  # Este método não recebe argumentos; usa @template definido por set_template.
  #
  # Este método não retorna valor; renderiza a visualização 'edit'.
  #
  # Efeitos colaterais: Garante que o question_set esteja carregado.
  def edit
    # @template is already set by before_action :set_template
    # Ensure question_set is loaded
    @template.build_question_set unless @template.question_set
  end

  # Atualiza um template existente.
  #
  # Este método recebe argumentos dos parâmetros da requisição através de template_params.
  #
  # Este método não retorna valor; redireciona ou renderiza com base na validação.
  #
  # Efeitos colaterais: Atualiza o Template e pode criar um novo QuestionSet (copy-on-write).
  def update
    params_hash = template_params
    question_set_data = extract_question_set_data(params_hash)

    if update_template(params_hash, question_set_data)
      redirect_to templates_path, notice: "Template updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Exclui um template.
  #
  # Este método não recebe argumentos; usa @template definido por set_template.
  #
  # Este método não retorna valor; redireciona após a exclusão.
  #
  # Efeitos colaterais: Remove o Template do banco de dados.
  def destroy
    @template.destroy
    redirect_to templates_path, notice: "Template deleted successfully"
  end

  private

  def extract_question_set_data(params_hash)
    question_set_params = params_hash.delete(:question_set_attributes)
    question_set_params&.dig(:data)
  end

  def update_template(params_hash, question_set_data)
    return false unless @template.update(params_hash)

    QuestionSetUpdateService.new(@template, question_set_data).call
    true
  end

  def set_template
    @template = current_admin.templates.includes(:question_set).find(params[:id])
  end

  def template_params
    permitted = params.require(:template).permit(:name, question_set_attributes: [ :id, :data ])

    # Parse the JSON data string into an array
    if permitted[:question_set_attributes] && permitted[:question_set_attributes][:data].is_a?(String)
      begin
        permitted[:question_set_attributes][:data] = JSON.parse(permitted[:question_set_attributes][:data])
      rescue JSON::ParserError
        # If parsing fails, leave it as is and let validation handle it
      end
    end

    permitted
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  def current_admin
    @current_admin ||= current_user&.admin
  end
end
