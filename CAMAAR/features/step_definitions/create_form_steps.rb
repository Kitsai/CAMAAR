# Step definitions for create form feature

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

Given("I am on the gerenciamento page") do
  visit gerenciamento_path
end

When("I click the send form button") do
  click_link "Enviar Formularios"
end

When("I select a template") do
  @selected_template = Template.first || FactoryBot.create(:template)
  select @selected_template.name, from: "template_id"
end

When("I do not select a template") do
  # Explicitly select the blank option if present
  select "", from: "template_id"
end

When("I select at least one class") do
  @selected_class = Klass.first || FactoryBot.create(:klass)
  
  # Select checkbox by value
  check("class_ids_#{@selected_class.id}")
end

When("I do not select any class") do
  # intentionally do nothing
end

# Success / Error Messages

Then("I should see a success message") do
  expect(page).to have_content("Formulário criado com sucesso")
end

Then("I should see an error message that I need to select a template") do
  expect(page).to have_content("É necessário selecionar um template")
end

Then("I should see an error message that I need to select at least one class") do
  expect(page).to have_content("É necessário selecionar pelo menos uma turma")
end

# Forms result assertions

Then("the new form should be assigned to the selected classes") do
  form = Form.last
  expect(form.klasses).to include(@selected_class)
end

Then("the new form should be available on the gerenciamento - results page") do
  visit forms_path  # adjust if your results page has a different path
  expect(page).to have_content(Form.last.name)
end