require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user.update(password: "password123", password_confirmation: "password123")
  end

  test "should get new" do
    get login_url
    assert_response :success
    assert_select "form"
  end

  test "should create session with valid credentials" do
    post login_url, params: {
      email: @user.email,
      password: "password123"
    }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
    assert_equal "Successfully logged in", flash[:notice]
  end

  test "should not create session with invalid email" do
    post login_url, params: {
      email: "wrong@example.com",
      password: "password123"
    }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_equal "Invalid email or password", flash[:alert]
  end

  test "should not create session with invalid password" do
    post login_url, params: {
      email: @user.email,
      password: "wrongpassword"
    }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_equal "Invalid email or password", flash[:alert]
  end

  test "should destroy session on logout" do
    # Login first
    post login_url, params: {
      email: @user.email,
      password: "password123"
    }
    assert_equal @user.id, session[:user_id]

    # Then logout
    delete logout_url
    assert_redirected_to root_path
    assert_nil session[:user_id]
    assert_equal "Successfully logged out", flash[:notice]
  end
end
