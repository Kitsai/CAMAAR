# Step definitions for export class performance feature

Given("I have created forms for some courses") do
  teacher = User.create!(
    email: 'teacher@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )

  @course1 = Course.create!(
    code: "CIC0097",
    name: "CIC0097 - BANCOS DE DADOS",
    semester: "2024.1",
    classCode: "A",
    teacher: teacher
  )

  @course2 = Course.create!(
    code: "CIC0202",
    name: "CIC0202 - PROGRAMAÇÃO CONCORRENTE",
    semester: "2024.1",
    classCode: "A",
    teacher: teacher
  )

  question_set = QuestionSet.create!(
    data: [
      { "text" => "Como você avalia o curso?", "type" => "text" },
      { "text" => "O que você aprendeu?", "type" => "text" }
    ]
  )

  @form1 = Form.create!(
    admin: @admin,
    course: @course1,
    question_set: question_set
  )

  @form2 = Form.create!(
    admin: @admin,
    course: @course2,
    question_set: question_set
  )
end

Given("there are student answers for these courses") do
  # Create answers for the first course
  Answer.create!(
    form: @form1,
    data: "Muito bom,Aprendi muito sobre SQL"
  )
  
  Answer.create!(
    form: @form1,
    data: "Excelente,Normalização de dados"
  )
end

When("I visit the results page") do
  visit forms_path
end

When("I click to export CSV for a course") do
  # Navigate directly to the CSV export for @form1
  visit export_form_csv_path(@form1.id)
end

When("I try to access the CSV export for a course I don't manage") do
  # Try to access a form that doesn't belong to this admin (using a non-existent form ID)
  visit export_form_csv_path(99999)
end

Then("I should see my courses listed") do
  expect(page).to have_content("CIC0097")
  expect(page).to have_content("CIC0202")
end

Then("I should download a CSV file with the class performance data") do
  verify_csv_download(page)
  verify_csv_content(page,
    'Como você avalia o curso?',
    'O que você aprendeu?',
    'Muito bom',
    'Aprendi muito sobre SQL')
end

Then("I should see an access denied message") do
  expect(page).to have_content('Você não tem permissão para acessar este formulário')
end

Then("no CSV file should be downloaded") do
  expect(page.response_headers['Content-Type']).not_to include('text/csv')
end
