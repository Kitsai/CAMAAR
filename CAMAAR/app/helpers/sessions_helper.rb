# Módulo auxiliar para gerenciar sessões de usuário, incluindo autenticação e verificações de papel.
module SessionsHelper
  # Retorna o usuário atualmente logado (se houver).
  #
  # Este método não recebe argumentos.
  #
  # Este método retorna um objeto User se houver um usuário logado, ou nil caso contrário.
  #
  # Este método não possui efeitos colaterais.
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Retorna verdadeiro se o usuário estiver logado, falso caso contrário.
  #
  # Este método não recebe argumentos.
  #
  # Este método retorna um valor booleano: true se logado, false se não.
  #
  # Este método não possui efeitos colaterais.
  def logged_in?
    !current_user.nil?
  end

  # Retorna verdadeiro se o usuário atual for um administrador.
  #
  # Este método não recebe argumentos.
  #
  # Este método retorna um valor booleano: true se for admin, false se não.
  #
  # Este método não possui efeitos colaterais.
  def admin?
    logged_in? && current_user.admin?
  end

  # Faz login do usuário fornecido.
  #
  # Este método recebe um argumento: user (um objeto User).
  #
  # Este método não retorna valor.
  #
  # Efeitos colaterais: Define session[:user_id] para o ID do usuário fornecido.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Faz logout do usuário atual.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor.
  #
  # Efeitos colaterais: Remove session[:user_id] da sessão e define @current_user para nil.
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
