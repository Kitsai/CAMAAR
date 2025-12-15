# Gerencia definição e redefinição de senhas de usuários
# Permite setup inicial e reset via email
class PasswordsController < ApplicationController
  skip_before_action :require_login

  # Exibe formulário para definir/redefinir senha
  def new
    @user = User.find_by(email: params[:email]) if params[:email]

    if @user&.password_digest.present?
      redirect_to login_path, alert: "Password already registered"
    end
  end

  # Processa a definição de senha para o usuário.
  #
  # Este método recebe argumentos dos parâmetros da requisição: params[:email], params[:password], params[:password_confirmation].
  #
  # Este método não retorna valor; redireciona ou renderiza com base na validação.
  #
  # Efeitos colaterais: Atualiza a senha do usuário no banco de dados se válido, redireciona para login_path com notice ou alerta.
  def create
    @user = find_user
    return render_user_not_found unless @user
    return redirect_password_already_set if password_already_set?
    return render_password_mismatch unless passwords_match?

    if set_user_password
      redirect_to login_path, notice: "Password set successfully"
    else
      flash.now[:alert] = "Failed to set password"
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Encontra o usuário pelo email fornecido.
  #
  # Este método não recebe argumentos; usa params[:email].
  #
  # Este método retorna um objeto User ou nil.
  #
  # Este método não possui efeitos colaterais.
  def find_user
    User.find_by(email: params[:email])
  end

  # Verifica se a senha do usuário já foi definida.
  #
  # Este método não recebe argumentos; usa @user.
  #
  # Este método retorna um valor booleano: true se a senha estiver definida, false caso contrário.
  #
  # Este método não possui efeitos colaterais.
  def password_already_set?
    @user.password_digest.present?
  end

  # Verifica se a senha e a confirmação coincidem.
  #
  # Este método não recebe argumentos; usa params[:password] e params[:password_confirmation].
  #
  # Este método retorna um valor booleano: true se coincidem, false caso contrário.
  #
  # Este método não possui efeitos colaterais.
  def passwords_match?
    params[:password] == params[:password_confirmation]
  end

  # Define a senha para o usuário.
  #
  # Este método não recebe argumentos; usa @user e params[:password], params[:password_confirmation].
  #
  # Este método retorna um valor booleano: true se a atualização for bem-sucedida, false caso contrário.
  #
  # Efeitos colaterais: Atualiza o password_digest do usuário no banco de dados.
  def set_user_password
    @user.update(
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
  end

  # Renderiza a visualização com erro de usuário não encontrado.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; renderiza a visualização 'new' com status unprocessable_entity.
  #
  # Efeitos colaterais: Define flash.now[:alert].
  def render_user_not_found
    flash.now[:alert] = "User not found"
    render :new, status: :unprocessable_entity
  end

  # Redireciona quando a senha já foi definida.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; redireciona para login_path.
  #
  # Efeitos colaterais: Redireciona com alerta.
  def redirect_password_already_set
    redirect_to login_path, alert: "Password already registered"
  end

  # Renderiza a visualização com erro de senhas não coincidem.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; renderiza a visualização 'new' com status unprocessable_entity.
  #
  # Efeitos colaterais: Define flash.now[:alert].
  def render_password_mismatch
    flash.now[:alert] = "Passwords do not match"
    render :new, status: :unprocessable_entity
  end
end
