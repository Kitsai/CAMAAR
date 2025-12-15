module TemplateRequestHelpers
  def create_template_with_question_set(name, admin, question_data = nil)
    question_data ||= [{ question: "Default question" }]
    Template.create!(
      name: name,
      admin: admin,
      question_set: QuestionSet.create!(data: question_data)
    )
  end

  def expect_templates_displayed(*template_names)
    template_names.each do |name|
      expect(response.body).to include(name)
    end
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "password123" }
  end

  def logout_user
    delete logout_path
  end

  def expect_redirects_to_root
    expect(response).to redirect_to(root_path)
  end

  def expect_admin_required_redirect
    expect_redirects_to_root
    expect(flash[:alert]).to include("Admin privileges required")
  end

  def switch_to_user(user)
    logout_user
    login_as(user)
  end

  def update_template_and_reload(template, new_attributes)
    patch template_path(template), params: { template: new_attributes }
    template.reload
  end
end

RSpec.configure do |config|
  config.include TemplateRequestHelpers, type: :request
end
