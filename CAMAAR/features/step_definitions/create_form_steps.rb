# Step definitions for create form feature

Given("I am an admin") do
  @admin = create_and_login_admin
end

Given("there is at least one template") do
  admin = Admin.first || FactoryBot.create(:admin)
  FactoryBot.create(:template, admin: admin)
end

Given("there is at least one class") do
  teacher = FactoryBot.create(:user)
  
  @course = FactoryBot.create(
    :course,
    teacher: teacher,
    semester: "2024.2",
    code: "CS101"
  )
end

Given("I am on the gerenciamento page") do
  visit gerenciamento_path
end

When("I open the send form modal") do
  click_button "Enviar Formulários"
end

When("I click the send form button") do
  click_button "Enviar"
end

When("I select a template") do
  @selected_template = Template.first || FactoryBot.create(:template)

  select_and_wait(@selected_template.name, from: "templateSelect")
end

When("I do not select a template") do
  select "", from: "templateSelect"
end

When("I select at least one class") do
  @selected_course = Course.first || FactoryBot.create(:course)
  
  # Select checkbox by value
  find("input[type='checkbox'][value='#{@selected_course.id}']").check
end

When("I do not select any class") do
  # intentionally do nothing
end

# Success / Error Messages

Then("I should see a success message") do
  expect(page).to have_content("Formulários criados com sucesso!")
end

Then("I should see an error message that I need to select a template") do
  expect(page).to have_content("É necessário selecionar um template")
end

Then("I should see an error message that I need to select at least one class") do
  expect(page).to have_content("É necessário selecionar pelo menos uma turma")
end

# Forms result assertions

Then("the new form should be assigned to the selected classes") do
  expect(Form.where(course: @selected_course)).to exist
end

Then("the new form should be available on the gerenciamento - results page") do
  visit forms_path  # adjust if your results page has a different path
  expect(page).to have_content(@selected_course.name)
end