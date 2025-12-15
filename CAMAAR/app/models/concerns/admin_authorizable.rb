# Concern para lógica de autorização de admin
#
# Uso:
#   class MyController < ApplicationController
#     include AdminAuthorizable
#     before_action :require_admin, only: [:admin_action]
#   end
#
# Métodos fornecidos:
#   - require_admin: Valida se o usuário atual é admin
#   - current_admin: Retorna o registro Admin do usuário atual
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
