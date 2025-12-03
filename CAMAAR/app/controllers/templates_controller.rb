class TemplatesController < ApplicationController
  before_action :require_admin
  before_action :set_template, only: [ :show, :edit, :update, :destroy ]

  def index
    @templates = current_admin.templates.includes(:question_set)
    @template = Template.new
    @template.build_question_set
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
    # @template is already set by before_action :set_template
    # Ensure question_set is loaded
    @template.build_question_set unless @template.question_set
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
    @template = current_admin.templates.includes(:question_set).find(params[:id])
  end

  def template_params
    permitted = params.require(:template).permit(:name, question_set_attributes: [ :id, :data ])

    # Parse the JSON data string into an array
    if permitted[:question_set_attributes] && permitted[:question_set_attributes][:data].is_a?(String)
      begin
        permitted[:question_set_attributes][:data] = JSON.parse(permitted[:question_set_attributes][:data])
      rescue JSON::ParserError
        # If parsing fails, leave it as is and let validation handle it
      end
    end

    permitted
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
