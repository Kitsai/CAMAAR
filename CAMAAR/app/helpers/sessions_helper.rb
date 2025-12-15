# Helpers para gerenciar sessões e autenticação de usuários
module SessionsHelper
  # Retorna o usuário atualmente logado
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Verifica se há um usuário logado
  def logged_in?
    !current_user.nil?
  end

  # Verifica se o usuário atual é admin
  def admin?
    logged_in? && current_user.admin?
  end

  # Faz login do usuário
  def log_in(user)
    session[:user_id] = user.id
  end

  # Faz logout do usuário atual
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
