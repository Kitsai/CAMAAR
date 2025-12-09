class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]
  before_action :redirect_if_logged_in, only: [ :new ]

  def new
    # Renders the login form
  end

  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      # Login successful
      session[:user_id] = user.id
      
      # Redirect to avaliacoes page
      redirect_to avaliacoes_path, notice: "Successfully logged in"
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

  private

  def redirect_if_logged_in
    if logged_in?
      redirect_to avaliacoes_path, notice: "You are already logged in"
    end
  end
end
