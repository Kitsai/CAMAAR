# frozen_string_literal: true

# Authentication helpers for Cucumber step definitions
# Provides reusable methods for user/admin creation and login patterns
module AuthenticationHelpers
  # Creates and logs in a standard user with default credentials
  #
  # @param email [String] User email (default: 'test@camaar.com')
  # @param password [String] User password (default: 'password123')
  # @return [User] The created user instance (also sets @user instance variable)
  # @example
  #   create_and_login_user
  #   create_and_login_user(email: 'custom@example.com')
  def create_and_login_user(email: 'test@camaar.com', password: 'password123')
    @user = FactoryBot.create(:user,
      email: email,
      password: password,
      password_confirmation: password
    )
    login_as(@user, password)
    @user
  end

  # Creates and logs in an admin user
  #
  # @param email [String] Admin user email (default: 'admin@example.com')
  # @param password [String] Admin user password (default: 'password123')
  # @return [Admin] The created admin instance (also sets @admin and @user instance variables)
  # @example
  #   create_and_login_admin
  #   create_and_login_admin(email: 'myadmin@example.com')
  def create_and_login_admin(email: 'admin@example.com', password: 'password123')
    @user = FactoryBot.create(:user,
      email: email,
      password: password,
      password_confirmation: password
    )
    @admin = FactoryBot.create(:admin, user: @user)
    login_as(@user, password)
    @admin
  end

  # Performs the actual login steps (shared between user and admin)
  #
  # @param user [User] The user to log in
  # @param password [String] The user's password
  # @example
  #   user = create_user
  #   login_as(user, 'password123')
  def login_as(user, password)
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Senha', with: password
    click_button 'Entrar'
  end

  # Creates a user without logging in (for specific scenarios)
  #
  # @param email [String] User email (default: 'test@camaar.com')
  # @param password [String] User password (default: 'password123')
  # @return [User] The created user instance
  # @example
  #   user = create_user(email: 'newuser@example.com')
  def create_user(email: 'test@camaar.com', password: 'password123')
    FactoryBot.create(:user,
      email: email,
      password: password,
      password_confirmation: password
    )
  end

  # Creates an admin without logging in
  #
  # @param email [String] Admin user email (default: 'admin@example.com')
  # @param password [String] Admin user password (default: 'password123')
  # @return [Admin] The created admin instance
  # @example
  #   admin = create_admin
  def create_admin(email: 'admin@example.com', password: 'password123')
    user = create_user(email: email, password: password)
    FactoryBot.create(:admin, user: user)
  end
end

World(AuthenticationHelpers)
