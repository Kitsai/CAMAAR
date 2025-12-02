class PasswordsController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.find_by(email: params[:email]) if params[:email]

    if @user&.password_digest.present?
      redirect_to login_path, alert: "Password already registered"
    end
  end

  def create
    @user = User.find_by(email: params[:email])

    if @user.nil?
      flash.now[:alert] = "User not found"
      render :new, status: :unprocessable_entity
      return
    end

    if @user.password_digest.present?
      redirect_to login_path, alert: "Password already registered"
      return
    end

    if params[:password] != params[:password_confirmation]
      flash.now[:alert] = "Passwords do not match"
      render :new, status: :unprocessable_entity
      return
    end

    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      redirect_to login_path, notice: "Passwords set successfully"
    else
      flash.now[:alert] = "Failed to set password"
      render :new, status: :unprocessable_entity
    end
  end
end
