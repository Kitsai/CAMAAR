require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "newuser@example.com",
      name: "New User"
      # No password set yet
    )
  end

  test "should get new" do
    get set_password_path(email: @user.email)
    assert_response :success
    assert_select "form"
  end

  test "should redirect if password already set" do
    @user.update(password: "existing", password_confirmation: "existing")
    get set_password_path(email: @user.email)
    assert_redirected_to login_path
    assert_equal "Password already registered", flash[:alert]
  end

  test "should create password with valid params" do
    post set_password_path, params: {
      email: @user.email,
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }
    assert_redirected_to login_path
    assert_equal "Password set successfully", flash[:notice]

    @user.reload
    assert @user.authenticate("newpassword123")
  end

  test "should not create password for non-existent user" do
    post set_password_path, params: {
      email: "nonexistent@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
    assert_response :unprocessable_entity
    assert_equal "User not found", flash[:alert]
  end

  test "should not create password if already set" do
    @user.update(password: "existing", password_confirmation: "existing")

    post set_password_path, params: {
      email: @user.email,
      password: "newpassword",
      password_confirmation: "newpassword"
    }
    assert_redirected_to login_path
    assert_equal "Password already registered", flash[:alert]
  end

  test "should not create password with mismatched confirmation" do
    post set_password_path, params: {
      email: @user.email,
      password: "password123",
      password_confirmation: "different123"
    }
    assert_response :unprocessable_entity
    assert_equal "Passwords do not match", flash[:alert]
  end

  test "should not create password with invalid password" do
    post set_password_path, params: {
      email: @user.email,
      password: "short",
      password_confirmation: "short"
    }
    assert_response :unprocessable_entity
    assert_equal "Failed to set password", flash[:alert]
  end
end
