# Step definitions for visualize templates feature

Given("I am on the {string} page") do |page_name|
  case page_name
  when "gerenciamento"
    # This would be the main admin management page
    # For now, we'll assume it's the templates index page
    visit templates_path
  else
    raise "Unknown page: #{page_name}"
  end
end

When("I click on {string} button") do |button_text|
  click_link button_text
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
  else
    "/#{path}"
  end
  expect(current_path).to eq(expected_path)
end

Then("I should see the templates list") do
  @templates.each do |template|
    expect(page).to have_content(template.name)
  end
end

Then("the {string} button should be disabled") do |button_text|
  # Check if button/link is disabled or not present
  expect(page).to have_css("a.disabled", text: button_text) ||
    expect(page).to have_css("button[disabled]", text: button_text)
end
