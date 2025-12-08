# Step definitions for view_unanswered_forms.feature

Given("I am logged in") do
  @user = FactoryBot.create(:user, email: 'user@camaar.com', password: 'password123', password_confirmation: 'password123')

  visit login_path
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'password123'
  click_button 'Entrar'

  expect(page).to have_current_path(avaliacoes_path)
end

Given("I am enrolled in a course") do
  @course = FactoryBot.create(:course)
  FactoryBot.create(:enrollment, student: @user, course: @course)
end

Given("I am enrolled in multiple courses") do
  @courses = []
  2.times do
    course = FactoryBot.create(:course)
    FactoryBot.create(:enrollment, student: @user, course: course)
    @courses << course
  end
end

Given("there is an unanswered form available for my course") do
  admin = FactoryBot.create(:user, :admin).admin
  question_set = FactoryBot.create(:question_set)

  @unanswered_form = FactoryBot.create(:form, admin: admin, course: @course, question_set: question_set)
  FormRequest.create!(user: @user, form: @unanswered_form)
end

Given("there is an unanswered form available") do
  admin = FactoryBot.create(:user, :admin).admin
  question_set = FactoryBot.create(:question_set)

  @unanswered_form = FactoryBot.create(:form, admin: admin, course: @course, question_set: question_set)
  FormRequest.create!(user: @user, form: @unanswered_form)
end

Given("there are unanswered forms available for my courses") do
  admin = FactoryBot.create(:user, :admin).admin
  @unanswered_forms = []

  @courses.each do |course|
    question_set = FactoryBot.create(:question_set)
    form = FactoryBot.create(:form, admin: admin, course: course, question_set: question_set)
    FormRequest.create!(user: @user, form: form)
    @unanswered_forms << form
  end
end

Given("there is a form I have already answered") do
  admin = FactoryBot.create(:user, :admin).admin
  question_set = FactoryBot.create(:question_set)

  # Create a different course for the answered form to distinguish it
  @answered_course = FactoryBot.create(:course)
  FactoryBot.create(:enrollment, student: @user, course: @answered_course)

  @answered_form = FactoryBot.create(:form, admin: admin, course: @answered_course, question_set: question_set)
  # Create answer and remove FormRequest to simulate answered form
  FactoryBot.create(:answer, form: @answered_form, data: "test,answer")
  # Don't create FormRequest - it gets removed when form is answered
end

Given("there are no unanswered forms available") do
  # Ensure no form requests exist for the user
  @user.form_requests.destroy_all
end

Given("there is a form for a course I am not enrolled in") do
  @other_course = FactoryBot.create(:course)
  admin = FactoryBot.create(:user, :admin).admin
  question_set = FactoryBot.create(:question_set)

  @restricted_form = FactoryBot.create(:form, admin: admin, course: @other_course, question_set: question_set)
end

When("I visit the forms page") do
  visit avaliacoes_path
end

When("I attempt to access the form directly") do
  # Try to access form without having a FormRequest
  visit form_path(@restricted_form) if defined?(form_path)
end

Then("I should see the unanswered form") do
  # The page shows course name as the title
  expect(page).to have_content(@unanswered_form.course.name)
end

Then("I should see a link to answer the form") do
  expect(page).to have_css('.template-card')
end

Then("I should see all unanswered forms from my courses") do
  @unanswered_forms.each do |form|
    expect(page).to have_content(form.course.name)
  end
end

Then("I should not see the answered form") do
  # The answered form course name should not appear
  expect(page).not_to have_content(@answered_form.course.name)
end

Then("I should see a message indicating no forms are available") do
  expect(page).to have_content("Nenhuma avaliação pendente")
end

Then("I should see a form unavailable message") do
  expect(page).to have_content("Este formulário não está mais disponível para você")
end

Then("I should not be able to view the form") do
  expect(page).not_to have_button('Enviar Avaliação')
end
