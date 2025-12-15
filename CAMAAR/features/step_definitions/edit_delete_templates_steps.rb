# Step definitions for edit and delete templates feature

Then("the edit modal should be displayed") do
  # First, refresh the page to show the newly created templates
  visit current_path

  # Now click the edit button on the first template
  if page.has_css?('.btn-edit')
    first('.btn-edit').click
  else
    raise "No edit button found - are there templates on the page?"
  end

  # Wait for the modal to be loaded via Turbo Frame
  # The modal might take a moment to appear due to async loading
  using_wait_time(5) do
    expect(page).to have_css('.modal.active', visible: true)
    expect(page).to have_content('Editar Template')
  end
end

Then("I should be able to edit the Templates") do
  # Wait for the modal to be fully displayed
  wait_for_modal

  # Store reference to the first template
  first_template = @templates.first

  # Fill in the edit form with new data
  fill_form_fields('Nome do Template' => 'Updated Template Name')

  # Save the changes
  click_button 'Atualizar'

  # Verify the template was updated successfully
  expect_success_message('Template updated successfully')
  expect(page).to have_content('Updated Template Name')

  # Verify in database
  first_template.reload
  expect(first_template.name).to eq('Updated Template Name')
end

Then("I should not be able to be able to edit the Templates") do
  # Verify that editing is not possible when there are no templates
  # No edit buttons should be present
  expect(page).not_to have_css('.btn-edit')

  # Modal should not be visible
  expect(page).not_to have_css('.modal.active', visible: true)
end

Then("the template should be deleted") do
  # First, refresh the page to show the newly created templates
  visit current_path

  # Now click the delete button on the first template
  click_first_with_confirm('.btn-delete', error_message: "No delete button found - are there templates on the page?")

  # Wait for the deletion to complete and verify success message
  expect_content_after_wait('Template deleted successfully')

  # Verify the template count decreased by 1
  # Only count templates for the current admin
  expect(@admin.templates.count).to eq(@templates.count - 1)
end

Then("I should see the atualized templates list") do
  # Verify that the templates list is displayed and updated
  # Check that remaining templates are visible or show empty state
  expect_list_or_empty_state(Template.all, 'No templates available', 'Nenhum template disponível')
end

Then("I should not be able to be able to delete the Templates") do
  # Verify that deletion is not possible when there are no templates
  # No delete buttons should be present
  expect(page).not_to have_css('.btn-delete')
end
