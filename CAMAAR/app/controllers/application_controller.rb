# Controlador base da aplicação.
#
# Todos os controladores herdam deste controlador, que fornece funcionalidades
# comuns como autenticação de usuário e validação de navegadores modernos.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Include session helpers for authentication
  include SessionsHelper

  before_action :require_login

  private

  # Valida se há um usuário logado antes de permitir acesso às páginas.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; redireciona se o usuário não estiver logado.
  #
  # Efeitos colaterais: Redireciona para login_path com alerta se o usuário não estiver logado.
  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end
end
