# Controlador responsável por gerenciar autenticação de usuários.
#
# Este controlador trata do login e logout de usuários no sistema.
class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]
  before_action :redirect_if_logged_in, only: [ :new ]

  # Renderiza a visualização do formulário de login.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; renderiza a visualização 'new'.
  #
  # Este método não possui efeitos colaterais.
  def new
    # Renders the login form
  end

  # Trata da autenticação e login do usuário.
  #
  # Este método recebe argumentos dos parâmetros da requisição: params[:email] e params[:password].
  #
  # Este método não retorna valor; redireciona em caso de sucesso ou renderiza a visualização 'new' em caso de falha.
  #
  # Efeitos colaterais: Em caso de autenticação bem-sucedida, define session[:user_id] para o ID do usuário e redireciona para avaliacoes_path com uma notificação. Em caso de falha, define um alerta flash e renderiza a visualização 'new' com status unprocessable_entity.
  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      # Login successful
      session[:user_id] = user.id

      redirect_to avaliacoes_path, notice: "Successfully logged in"
    else
      # Login failed
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  # Faz logout do usuário atual limpando a sessão.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; redireciona para o caminho raiz.
  #
  # Efeitos colaterais: Define session[:user_id] para nil e redireciona para root_path com uma notificação.
  def destroy
    # Logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Successfully logged out"
  end

  private

  # Redireciona usuários logados para a página apropriada com base no papel deles.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; redireciona com base no papel do usuário.
  #
  # Efeitos colaterais: Se o usuário estiver logado e for admin, redireciona para forms_path com uma notificação. Se logado mas não admin, redireciona para avaliacoes_path com uma notificação.
  def redirect_if_logged_in
    if logged_in?
      if current_user.admin?
        redirect_to forms_path, notice: "You are already logged in"
      else
        redirect_to avaliacoes_path, notice: "You are already logged in"
      end
    end
  end
end
