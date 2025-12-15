# Controlador base para áreas que requerem privilégios de administrador.
#
# Este controlador deve ser herdado por outros controladores que implementam
# funcionalidades exclusivas para usuários com perfil de admin.
class AdminController < ApplicationController
  before_action :require_admin

private

  # Valida se o usuário atual possui privilégios de administrador.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; redireciona se o usuário não for admin.
  #
  # Efeitos colaterais: Redireciona para root_path com alerta se o usuário não for admin.
  def require_admin
    unless admin?
      redirect_to root_path, alert: "Acess denied, Admin privaleges required."
    end
  end
end
