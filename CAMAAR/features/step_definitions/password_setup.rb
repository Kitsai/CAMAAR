Given("I received a registration email") do
  @user = User.create!(
    email: 'user@example.com'
  )
end

Given("I already have a password") do
  @user ||= User.create!(
    email: 'user@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
end

####

When("I click on the registration link") do
  visit set_password_path(email: @user.email)
end

When("I enter a valid password") do
  fill_in 'Senha', with: 'password123'
end

When("I confirm the password correctly") do
  fill_in 'Confirmar', with: 'password123'
  click_button 'Definir Senha'
end

When("I enter a different password in the confirmation field") do
  fill_in 'Confirmar', with: 'senha123'
  click_button 'Definir Senha'
end

####

Then("I should see a success message") do
  assert page.has_content?('Password set successfully')
end

Then("I should be able to log in with my credentials") do
  visit login_path
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'password123'
  click_button 'Entrar'
  assert page.has_content?('Successfully logged in')
end

Then("I should see an error message that passwords do not match") do
  assert page.has_content?('Passwords do not match')
end

Then("I should see an error message that password already registered") do
  assert page.has_content?('Password already registered')
end
