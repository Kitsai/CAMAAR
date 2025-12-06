class FormsController < ApplicationController
  before_action :require_admin

  def index
    @forms = current_admin.forms.includes(:course, :question_set)
  end

  private

  def current_admin
    @current_admin ||= current_user&.admin
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
