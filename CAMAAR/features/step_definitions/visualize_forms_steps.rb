# Step definitions for visualize forms feature

# Reuse "I am an admin" from create_template_steps.rb
# This step already exists and handles admin creation + login

Given("I am in {string} page") do |page_name|
  case page_name
  when "gerenciamento"
    # For now, visit templates path as gerenciamento dashboard doesn't exist yet
    # This will be updated when the actual gerenciamento page is created
    visit templates_path
  when "gerenciamento/resultados"
    visit "/gerenciamento/resultados"
  else
    raise "Unknown page: #{page_name}"
  end
end

When("I click in {string} button") do |button_text|
  click_link_or_button button_text
end

Given("there are not created forms") do
  # Ensure no forms exist for this admin
  @admin.forms.destroy_all if @admin
end

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

Then("I should be redirected to {string}") do |path|
  expected_path = case path
  when "gerenciamento/resultados"
    "/gerenciamento/resultados"
  when "gerenciamento/templates"
    templates_path
  else
    "/#{path}"
  end
  expect(current_path).to eq(expected_path)
end

Then("I should view the page with created Forms") do
  # Verify we're on the forms page and can see forms
  expect(page).to have_current_path("/gerenciamento/resultados")
  
  # Check that forms are displayed
  @forms.each do |form|
    expect(page).to have_content(form.course.name)
  end
end

Then("the button should not be clickable") do
  # When there are no forms, the "Resultados" button should be disabled or not present
  # This could be implemented as:
  # 1. Button with disabled attribute
  # 2. Link with disabled class
  # 3. Button that's not rendered at all
  
  # Check for disabled state or absence
  resultados_button = page.all('a, button', text: 'Resultados').first
  
  if resultados_button
    # If button exists, it should be disabled
    expect(
      resultados_button[:class].to_s.include?('disabled') ||
      resultados_button[:disabled] == 'disabled' ||
      resultados_button[:disabled] == true
    ).to be true
  else
    # Button not being present is also acceptable when there are no forms
    expect(page).not_to have_link_or_button('Resultados')
  end
end
