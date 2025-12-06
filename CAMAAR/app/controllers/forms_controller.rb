class FormsController < ApplicationController
  def index
    # Show forms that the current user needs to respond to
    # Uses the form_requests relationship table
    @forms = current_user.forms.includes(:course, :question_set)
  end
end
