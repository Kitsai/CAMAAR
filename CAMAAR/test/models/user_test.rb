require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      name: "Test User"
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should require unique email" do
    @user.save!
    duplicate_user = User.new(email: @user.email, password: "password")
    assert_not duplicate_user.valid?
  end

  test "should have secure password" do
    assert_respond_to @user, :authenticate
  end

  test "should authenticate with correct password" do
    @user.save!
    assert @user.authenticate("password123")
  end

  test "should not authenticate with wrong password" do
    @user.save!
    assert_not @user.authenticate("wrongpassword")
  end

  test "admin? should return true when user has admin record" do
    @user.save!
    Admin.create!(user: @user)
    assert @user.admin?
  end

  test "admin? should return false when user has no admin record" do
    @user.save!
    assert_not @user.admin?
  end

  test "should have many taught_courses" do
    assert_respond_to @user, :taught_courses
  end

  test "should have many enrollments" do
    assert_respond_to @user, :enrollments
  end

  test "should have many courses through enrollments" do
    assert_respond_to @user, :courses
  end

  test "should have one admin association" do
    assert_respond_to @user, :admin
  end
end
