# Step definitions for submit_form.feature

Given("I am on the Avaliações page") do
  # Create a user and log in
  create_and_login_user

  expect(page).to have_current_path(avaliacoes_path)
end

Given("there are available forms") do
  # Create forms and assign to the user
  admin = FactoryBot.create(:user, :admin).admin
  question_set = FactoryBot.create(:question_set)
  course = FactoryBot.create(:course)
  
  @form = FactoryBot.create(:form, admin: admin, course: course, question_set: question_set)
  FormRequest.create!(user: @user, form: @form)
  
  # Refresh the page to see the newly created forms
  visit forms_path
end

Given("there are no available forms") do
  # Ensure no forms are assigned to the user
  @user.form_requests.destroy_all if @user
end

When("I click on an available form") do
  # Wait for page to fully load with forms
  expect(page).to have_css('.template-card', wait: 5)
  
  # Click on the first form card
  @selected_form = @user.forms.first
  # Modal will open via turbo frame
  find('.template-card', match: :first).click
end

Then("I should be redirected to the selected form page") do
  # With modal, we check that modal is visible instead of URL change
  expect_form_modal_with_content(@selected_form)
end

When("I answer all questions in the form") do
  # Wait for modal to be visible
  wait_for_modal

  # Fill in all questions based on the form's question_set
  answer_form_questions(@selected_form)
end

When("I click on the send button") do
  click_button 'Enviar Avaliação'
end

Then("the form should be submitted successfully") do
  expect(page).to have_content('Avaliação enviada com sucesso')
end

Then("I should be redirected back to the Avaliações page") do
  expect(page).to have_current_path(avaliacoes_path)
end

Then("I should be redirected to the Avaliações page") do
  expect(page).to have_current_path(avaliacoes_path)
end

Then("the submitted form should no longer be available") do
  expect(page).not_to have_content(@selected_form.course.name)
end

Then("I should see a message indicating that no forms are available") do
  expect(page).to have_content("Nenhuma avaliação pendente")
end

Then("no form items should be displayed") do
  expect(page).not_to have_css('.template-card')
end

Given("I am viewing an available form") do
  # Setup similar to "I am on the Avaliações page" + "there are available forms"
  create_and_login_user

  admin = FactoryBot.create(:user, :admin).admin
  question_set = FactoryBot.create(:question_set)
  course = FactoryBot.create(:course)

  @form = FactoryBot.create(:form, admin: admin, course: course, question_set: question_set)
  @form_request = FormRequest.create!(user: @user, form: @form)

  # Refresh the page to show the newly created forms
  visit forms_path

  # Click on the form to open modal
  open_modal_and_wait('.template-card')
end

Given("I have not answered all mandatory questions") do
  # Don't fill in any questions - just skip this step
  # The form should have validation requiring all questions to be answered
end

Then("the form should not be submitted") do
  # Verify no answer was created for this form
  expect(Answer.where(form: @form).count).to eq(0)
  
  # If modal is active, we're still on the form page (validation error scenario)
  # If modal is not active, we've been redirected (unavailable form scenario)
  # Both cases are valid "not submitted" states
end

Then("I should see a validation error message") do
  expect(page).to have_content('Por favor, responda todas as questões obrigatórias')
end

Then("I should remain on the form page") do
  # Modal should still be visible
  expect(page).to have_css('.modal.active', visible: true)
end

Given("the form has become unavailable") do
  # Delete the form_request to simulate the form becoming unavailable
  @form_request.destroy
end

Then("I should see a message that the form is no longer available") do
  expect(page).to have_content('Este formulário não está mais disponível')
end

