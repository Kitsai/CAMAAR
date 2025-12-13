module AdminAuthorizable
  extend ActiveSupport::Concern

  private

  def require_admin
    unless current_user&.admin?
      redirect_to avaliacoes_path, alert: "Acesso negado"
      false
    end
  end

  def current_admin
    current_user&.admin
  end
end
