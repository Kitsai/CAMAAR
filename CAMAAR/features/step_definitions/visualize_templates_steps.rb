# Step definitions for visualize templates feature

Given("I am on the {string} page") do |page_name|
  case page_name
  when "gerenciamento"
    visit gerenciamento_path
  when "gerenciamento/templates"
    visit templates_path
  when "gerenciamento/resultados"
    visit forms_path
  else
    raise "Unknown page: #{page_name}"
  end
end

Given('I am on {string} page') do |page_name|
  case page_name
  when "gerenciamento"
    visit gerenciamento_path
  when "gerenciamento/resultados"
    visit forms_path
  else
    visit "/#{page_name}"
  end
end

def handle_import_button
  # In non-JavaScript tests, confirmation dialogs are automatically accepted
  if Capybara.current_driver == Capybara.javascript_driver
    accept_confirm { click_button "Importar Dados" }
  else
    click_button "Importar Dados"
  end
end

When("I click on {string} button") do |button_text|
  # Map "Resultados" to "Avaliações" since we renamed it in the sidebar
  button_text = "Avaliações" if button_text == "Resultados"

  # Handle "Importar dados" button (button_to with confirmation)
  if button_text.downcase == "importar dados"
    handle_import_button
  # For "Editar templates" from gerenciamento page, navigate to templates
  elsif button_text == "Editar templates" && current_path == "/gerenciamento"
    click_link "Editar Templates"
  elsif button_text == "Editar templates" || button_text == "Deletar templates"
    @button_to_click = button_text
  else
    click_link button_text
  end
end

When('I click on the {string} button') do |button_text|
  # Handle "Importar dados" button (button_to with confirmation)
  if button_text.downcase == "importar dados"
    handle_import_button
  else
    click_link button_text
  end
end

Given("there are created templates") do
  # Create some sample templates
  @templates = []
  3.times do |i|
    question_set = QuestionSet.create!(
      data: [
        { question: "Question #{i + 1}?", type: "text" }
      ]
    )
    @templates << Template.create!(
      name: "Template #{i + 1}",
      admin: @admin,
      question_set: question_set
    )
  end
end

Given("there are no created templates") do
  # Ensure no templates exist for this admin
  @admin.templates.destroy_all
end

Then("I should be redirected to {string}") do |path|
  expected_path = case path
  when "gerenciamento/templates"
    templates_path
  when "gerenciamento/resultados"
    "/gerenciamento/resultados"
  else
    "/#{path}"
  end
  expect(current_path).to eq(expected_path)
end

Then("I should see the templates list") do
  # Refresh the page to show the newly created templates
  visit current_path

  @templates.each do |template|
    expect(page).to have_content(template.name)
  end
end

Then("the {string} button should be disabled") do |button_text|
  case button_text
  when "Editar templates"
    # When there are no templates, edit buttons should not be present
    expect_no_action_buttons('.btn-edit')
  when "Deletar templates"
    # When there are no templates, delete buttons should not be present
    expect_no_action_buttons('.btn-delete')
  else
    # Check if button/link is disabled or not present
    expect_button_disabled(button_text)
  end
end
