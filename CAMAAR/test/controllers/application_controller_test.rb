require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user.update(password: "password123", password_confirmation: "password123")
  end

  test "current_user returns user when logged in" do
    post login_url, params: { email: @user.email, password: "password123" }
    get root_url
    assert_equal @user.id, session[:user_id]
  end

  test "current_user returns nil when not logged in" do
    get root_url
    assert_nil session[:user_id]
  end

  test "logged_in? returns true when user is logged in" do
    post login_url, params: { email: @user.email, password: "password123" }
    assert_equal @user.id, session[:user_id]
  end

  test "logged_in? returns false when user is not logged in" do
    get root_url
    assert_nil session[:user_id]
  end

  test "require_login redirects to login when not logged in" do
    # Try to access a protected page (templates requires admin which requires login)
    get templates_url
    assert_redirected_to login_path
    assert_equal "You must be logged in to acces this page.", flash[:alert]
  end

  test "require_login allows access when logged in" do
    # @user already has an admin association from fixtures (admins(:one))
    # Just login
    post login_url, params: { email: @user.email, password: "password123" }

    # Try to access protected page
    get templates_url
    assert_response :success
  end
end
