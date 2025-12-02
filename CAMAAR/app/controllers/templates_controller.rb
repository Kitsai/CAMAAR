class TemplatesController < ApplicationController
  before_action :require_admin
  before_action :set_template, only: [ :show, :edit, :update, :destroy ]

  def index
    @templates = current_admin.templates.includes(:question_set)
  end

  def new
    @template = Template.new
    @template.build_question_set
  end

  def create
    @template = current_admin.templates.build(template_params)

    if @template.save
      redirect_to templates_path, notice: "Template created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to templates_path, notice: "Template updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.destroy
    redirect_to templates_path, notice: "Template deleted successfully"
  end

  private

  def set_template
    @template = current_admin.templates.find(params[:id])
  end

  def template_params
    params.require(:template).permit(:name, question_set_attributes: [ :id, :data ])
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  def current_admin
    @current_admin ||= current_user&.admin
  end
end
