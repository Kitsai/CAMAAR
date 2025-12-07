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
