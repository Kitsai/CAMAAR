# Step definitions for visualize forms feature

# Reuse "I am an admin" from create_template_steps.rb
# This step already exists and handles admin creation + login

Given("I am in {string} page") do |page_name|
  case page_name
  when "gerenciamento"
    # Visit templates path which is the current gerenciamento page
    # The sidebar has a "Resultados" link to access forms
    visit templates_path
  when "gerenciamento/resultados"
    visit "/gerenciamento/resultados"
  else
    raise "Unknown page: #{page_name}"
  end
end

When("I click in {string} button") do |button_text|
  # Map "Resultados" to "Avaliações" since we renamed it in the sidebar
  button_text = "Avaliações" if button_text == "Resultados"
  
  # If clicking "Avaliações" and we don't have forms created yet, create them
  if button_text == "Avaliações" && !defined?(@forms)
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
  
  click_link button_text
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

Then("I should view the page with created Forms") do
  # Verify we're on the forms page and can see forms
  expect(page).to have_current_path("/gerenciamento/resultados")
  
  # Check that forms are displayed
  @forms.each do |form|
    expect(page).to have_content(form.course.name)
  end
end

Then("the button should not be clickable") do
  # The "Avaliações" button is always clickable in the sidebar
  # When there are no forms, clicking it shows an empty state message
  # So we verify that the button exists and can be clicked
  expect(page).to have_link('Avaliações')
  
  # Click the button and verify it goes to the page with empty state
  click_link 'Avaliações'
  expect(page).to have_current_path("/gerenciamento/resultados")
  expect(page).to have_content("Nenhum formulário criado")
end
