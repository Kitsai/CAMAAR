# Step definitions for importing data

# Background steps
# Note: "I am on {string} page" is in visualize_templates_steps.rb

Given("there is importable data") do
  @importable_data = [
    { id: 1, name: "Item válido 1" },
    { id: 2, name: "Item válido 2" }
  ]
end

Given("there is no importable data") do
  @importable_data = []
end

Given("there is importable data with an invalid format") do
  @importable_data = [
    { id: 1, name: nil } # exemplo inválido
  ]
end

Given("there is importable data with some invalid data") do
  @importable_data = [
    { id: 1, name: "Item válido" },
    { id: 2, name: nil } # inválido
  ]
end

# When steps - Actions
# Note: "I click on {string} button" steps are in visualize_templates_steps.rb

# Then Steps - Assertions

Then("the importable data should be imported") do
  expect(ImportService.imported_items).to include(*@importable_data)
end

Then("I should see a message indicating that no data is available to import") do
  expect(page).to have_content("Nenhum dado disponível para importação")
end

Then("no data should be imported") do
  expect(ImportService.imported_items).to be_empty
end

Then("I should see an error message indicating the data format is invalid") do
  expect(page).to have_content("Formato de dados inválido")
end

Then("the import should be aborted") do
  expect(ImportService.imported_items).to be_empty
end

Then("the valid data should be imported") do
  valid_data = @importable_data.reject { |d| d[:name].nil? }
  expect(ImportService.imported_items).to eq(valid_data)
end

Then("I should see a warning indicating that some data could not be imported") do
  expect(page).to have_content("Alguns dados não puderam ser importados")
end

# Additional workflow steps

Given('I have clicked on the {string} button') do |button_text|
  click_button button_text
end

When('the data is imported') do
  expect(page).to have_content('Import completed')
end

When('the data import fails') do
  expect(page).to have_content('Import failed')
end