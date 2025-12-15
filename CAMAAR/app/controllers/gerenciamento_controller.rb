# Controlador responsável pela página principal de gerenciamento de admins.
#
# Este controlador exibe templates, cursos e formulários, permitindo
# que admins gerenciem o sistema.
class GerenciamentoController < ApplicationController
  before_action :require_admin

  # Renderiza a página principal de gerenciamento.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; renderiza a visualização 'index'.
  #
  # Efeitos colaterais: Carrega templates, cursos e inicializa objetos para formulários.
  def index
    @templates = current_admin.templates.includes(:question_set)
    @template = Template.new
    @courses = Course.includes(:students, :teacher).all
    @form = Form.new
  end

  private
  
  # Valida se o usuário atual possui privilégios de administrador.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; redireciona se o usuário não for admin.
  #
  # Efeitos colaterais: Redireciona para root_path com alerta se o usuário não for admin.
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  # Retorna o registro Admin do usuário atual.
  #
  # Este método não recebe argumentos.
  #
  # Este método retorna um objeto Admin ou nil.
  #
  # Este método não possui efeitos colaterais.
   def current_admin
    @current_admin ||= current_user&.admin
  end

end
