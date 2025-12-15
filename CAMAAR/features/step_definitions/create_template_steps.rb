# Step definitions for create template feature

Given("I am on the gerenciamento - templates page") do
  visit templates_path
end

When("I click the add button") do
  # Click the add template button (the card with + icon)
  find('.add-template-card').click
end

When("I enter a valid name") do
  # Wait for modal to be visible
  expect(page).to have_css('.modal.active', visible: true)
  fill_in 'Nome do Template', with: 'Test Template'
end

When("I enter a invalid name") do
  expect_modal_visible
  fill_template_name('')
  add_question_to_template('Text', 'Test question')
  submit_template_creation
end

When("I add at least one question") do
  # Click the add question button
  find('.btn-add-question').click

  # Fill in the first question
  within(first('.question-item')) do
    find('.question-type-select').select('Text')
    find('.question-input').fill_in with: 'What is your name?'
  end

  # Submit the form
  click_button 'Criar'
end

When("I do not add questions") do
  # Wait for modal to be visible
  expect(page).to have_css('.modal.active', visible: true)

  # Fill in the name field so we can submit
  fill_in 'Nome do Template', with: 'Test Template Without Questions'

  # Submit the form without adding any questions
  find('.btn-submit').click
end

Then("the new template should appear in the template list") do
  expect(page).to have_content('Test Template')
  expect(page).to have_content('Template created successfully')
end

Then("I should receive an error that I should add questions") do
  # Check that the form wasn't submitted successfully
  expect(page).not_to have_content('Template created successfully')

  # Check that we're still on the form/new page (not redirected back to index)
  expect(page).to have_content('Novo Template')

  # The validation should have prevented creation
  expect(Template.count).to eq(0)
end

Then("I should receive an error that I should add a name") do
  # Check that the form wasn't submitted successfully
  expect(page).not_to have_content('Template created successfully')

  # Check that we're still on the form/new page
  expect(page).to have_content('Novo Template')

  # The validation should have prevented creation
  expect(Template.count).to eq(0)
end
