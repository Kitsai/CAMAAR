# Página principal de gerenciamento para admins
# Exibe templates, cursos e permite criar formulários
class GerenciamentoController < ApplicationController
  before_action :require_admin

  def index
    @templates = current_admin.templates.includes(:question_set)
    @template = Template.new
    @courses = Course.includes(:students, :teacher).all
    @form = Form.new
  end

  private
  
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

   def current_admin
    @current_admin ||= current_user&.admin
  end

end
