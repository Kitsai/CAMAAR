# Step definitions for user login feature

# Background steps
Given('I am on login page') do
  visit login_path
end

Given('I am an admin user') do
  # Create a user with admin privileges
  @user = User.create!(
    email: 'admin@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  @admin = Admin.create!(user: @user)
end

# When steps - Actions
When('I enter a valid email') do
  @user ||= User.create!(
    email: 'user@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  fill_in 'Email', with: @user.email
end

When('I enter the correct password') do
  fill_in 'Senha', with: 'password123'
  click_button 'Entrar'
end

When('I enter a email that does not exist on database') do
  fill_in 'Email', with: 'nonexistent@example.com'
  fill_in 'Senha', with: 'password123'
  click_button 'Entrar'
end

When('I enter the wrong password') do
  @user ||= User.create!(
    email: 'user@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'wrongpassword'
  click_button 'Entrar'
end

When('I log in successfully') do
  visit login_path
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'password123'
  click_button 'Entrar'
end

# Then steps - Assertions
Then('I should see the homepage') do
  assert_equal root_path, current_path
  assert page.has_content?('Successfully logged in')
end

Then('I should see an error message that user does not exist') do
  assert page.has_content?('Invalid email or password')
end

Then('I should see an error message that the password is wrong') do
  assert page.has_content?('Invalid email or password')
end

Then('I should see the gerenciamento tab on the side menu') do
  assert page.has_link?('Gerenciamento')
end
