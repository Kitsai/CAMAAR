# Step definitions for create template feature

Given("I am an admin") do
  @user = User.create!(
    email: 'admin@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  @admin = Admin.create!(user: @user)

  # Log in as admin
  visit login_path
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'password123'
  click_button 'Entrar'
end

Given("I am on the gerenciamento - templates page") do
  visit templates_path
end

When("I click the add button") do
  click_link 'Add Template'
end

When("I enter a valid name") do
  fill_in 'Name', with: 'Test Template'
end

When("I enter a invalid name") do
  fill_in 'Name', with: ''
end

When("I add at least one question") do
  # Assuming we have a form field for questions data as JSON
  fill_in 'Questions', with: '[{"question": "What is your name?", "type": "text"}]'
  click_button 'Create Template'
end

When("I do not add questions") do
  fill_in 'Questions', with: ''
  click_button 'Create Template'
end

Then("the new template should appear in the template list") do
  expect(page).to have_content('Test Template')
  expect(page).to have_content('Template created successfully')
end

Then("I should receive an error that I should add questions") do
  expect(page).to have_content('must have at least one question')
end

Then("I should receive an error that I should add a name") do
  expect(page).to have_content("Name can't be blank")
end
