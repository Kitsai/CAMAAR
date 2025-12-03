class PasswordsController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.find_by(email: params[:email]) if params[:email]

    if @user&.password_digest.present?
      redirect_to login_path, alert: "Password already registered"
    end
  end

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

  def find_user
    User.find_by(email: params[:email])
  end

  def password_already_set?
    @user.password_digest.present?
  end

  def passwords_match?
    params[:password] == params[:password_confirmation]
  end

  def set_user_password
    @user.update(
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
  end

  def render_user_not_found
    flash.now[:alert] = "User not found"
    render :new, status: :unprocessable_entity
  end

  def redirect_password_already_set
    redirect_to login_path, alert: "Password already registered"
  end

  def render_password_mismatch
    flash.now[:alert] = "Passwords do not match"
    render :new, status: :unprocessable_entity
  end
end
