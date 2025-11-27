class AdminController < ApplicationController
  before_action :require_admin

private

  def require_admin
    unless admin?
      redirect_to root_path, alert: "Acess denied, Admin privaleges required."
    end
  end
end
