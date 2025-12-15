# Step definitions for admin visualize forms feature

# Reuse "I am an admin" from create_template_steps.rb
# This step already exists and handles admin creation + login

# Reuse "I am in gerenciamento page" from visualize_templates (via "I am on the {string} page")
# Reuse "I click on {string} button" from visualize_templates
# Reuse "I should be redirected to {string}" from visualize_templates

Given("there are created forms") do
  # Create some sample forms for the admin
  @forms = []
  3.times do |i|
    question_set = FactoryBot.create(:question_set)
    course = FactoryBot.create(:course)
    @forms << FactoryBot.create(:form,
      admin: @admin,
      course: course,
      question_set: question_set
    )
  end
end

Given("there are no created forms") do
  # Ensure no forms exist for this admin
  @admin.forms.destroy_all if @admin
end

When("I click in {string} button") do |button_text|
  click_link button_text
end

Then("I should view the page with created forms") do
  # Check that forms are displayed
  @forms.each do |form|
    expect(page).to have_content(form.course.name)
  end
end

Then("I should see a message indicating no forms exist") do
  expect(page).to have_content("Nenhum formulário criado")
end

# Steps for generate_report feature

When("I click on a form") do
  first('.form-card, a').click
end

When("an internal error occurs during report generation") do
  pending "Internal error simulation needs implementation"
end

When("the form is no longer available") do
  @forms.each(&:destroy) if @forms
end

Then("a CSV file containing the form responses should be downloaded") do
  expect(page.response_headers['Content-Type']).to include('text/csv')
end

Then("I should see an error message indicating that the report could not be generated") do
  expect(page).to have_content(/Erro|Error/)
end

Then("I should see a message indicating that the form cannot be accessed") do
  expect(page).to have_content(/não encontrado|not found/)
end
