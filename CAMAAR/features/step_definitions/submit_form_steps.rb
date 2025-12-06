# Step definitions for submit_form.feature

Given("I am on the Avaliações page") do
  # Create a user and log in
  @user = FactoryBot.create(:user, email: 'test@camaar.com', password: 'password123', password_confirmation: 'password123')
  
  visit login_path
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'password123'
  click_button 'Entrar'
  
  expect(page).to have_current_path(forms_path)
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
  expect(page).to have_css('.modal.active', visible: true)
  expect(page).to have_content(@selected_form.course.name)
  expect(page).to have_button('Enviar Avaliação')
end

When("I answer all questions in the form") do
  # Fill in all questions based on the form's question_set
  questions = @selected_form.question_set.data
  
  # Wait for modal to be visible
  expect(page).to have_css('.modal.active', visible: true)
  
  questions.each_with_index do |question, index|
    case question["type"]
    when "text"
      fill_in "answers[#{index}][answer]", with: "This is my answer to: #{question['question']}"
    when "radio"
      # Select the first option
      choose "answer_#{index}_0" if question["options"]&.any?
    end
  end
end

When("I click on the send button") do
  click_button 'Enviar Avaliação'
end

Then("the form should be submitted successfully") do
  expect(page).to have_content('Avaliação enviada com sucesso')
end

Then("I should be redirected back to the Avaliações page") do
  expect(page).to have_current_path(forms_path)
end

Then("I should be redirected to the Avaliações page") do
  expect(page).to have_current_path(forms_path)
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
  @user = FactoryBot.create(:user, email: 'test@camaar.com', password: 'password123', password_confirmation: 'password123')
  
  admin = FactoryBot.create(:user, :admin).admin
  question_set = FactoryBot.create(:question_set)
  course = FactoryBot.create(:course)
  
  @form = FactoryBot.create(:form, admin: admin, course: course, question_set: question_set)
  @form_request = FormRequest.create!(user: @user, form: @form)
  
  # Login and open the form modal
  visit login_path
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'password123'
  click_button 'Entrar'
  
  # Click on the form to open modal
  find('.template-card', match: :first).click
  
  # Wait for modal to appear
  expect(page).to have_css('.modal.active', visible: true)
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

