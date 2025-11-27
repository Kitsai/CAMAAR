class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    # Renders the login form
  end

  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      # Login successful
      session[:user_id] = user.id
      redirect_to root_path, notice: "Successfully logged in"
    else
      # Login failed
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # Logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Successfully logged out"
  end
end
