require "test_helper"

class TemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin = admins(:one)
    @template = templates(:one)
    @non_admin_user = User.create!(
      email: "nonadmin@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should redirect to login if not logged in" do
    get templates_url
    assert_redirected_to login_path
    assert_equal "You must be logged in to acces this page.", flash[:alert]
  end

  test "should redirect to root if not admin" do
    log_in_as(@non_admin_user)
    get templates_url
    assert_redirected_to root_path
    assert_equal "Access denied. Admin privileges required.", flash[:alert]
  end

  test "should get index when logged in as admin" do
    log_in_as(@admin_user)
    get templates_url
    assert_response :success
  end

  test "should show all templates for current admin on index" do
    log_in_as(@admin_user)
    get templates_url
    assert_response :success

    # Should show templates belonging to this admin
    assert_select "h1, h2, h3, h4, h5, h6, p, div", text: /#{@template.name}/
  end

  test "should only show templates for current admin" do
    # Create another admin with their own template
    other_user = User.create!(
      email: "otheradmin@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    other_admin = Admin.create!(user: other_user)
    other_question_set = QuestionSet.create!(
      data: [ { "question": "Other question?", "type": "text" } ]
    )
    other_template = Template.create!(
      name: "Other Admin Template",
      admin: other_admin,
      question_set: other_question_set
    )

    log_in_as(@admin_user)
    get templates_url
    assert_response :success

    # Should show own templates
    assert_match @template.name, response.body

    # Should NOT show other admin's templates
    assert_no_match other_template.name, response.body
  end

  private

  def log_in_as(user)
    post login_url, params: { email: user.email, password: "password123" }
  end
end
