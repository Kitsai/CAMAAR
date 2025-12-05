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
  expect(page).to have_css('.modal.active', visible: true)

  # Store reference to the first template
  first_template = @templates.first

  # Fill in the edit form with new data
  fill_in 'Nome do Template', with: 'Updated Template Name'

  # Save the changes
  click_button 'Atualizar'

  # Verify the template was updated successfully
  expect(page).to have_content('Template updated successfully')
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
  if page.has_css?('.btn-delete')
    accept_confirm do
      first('.btn-delete').click
    end
  else
    raise "No delete button found - are there templates on the page?"
  end

  # Wait for the deletion to complete and page to reload
  using_wait_time(5) do
    # Verify success message is shown
    expect(page).to have_content('Template deleted successfully')
  end

  # Verify the template count decreased by 1
  # Only count templates for the current admin
  expect(@admin.templates.count).to eq(@templates.count - 1)
end

Then("I should see the atualized templates list") do
  # Verify that the templates list is displayed and updated
  # Check that remaining templates are visible
  remaining_templates = Template.all

  if remaining_templates.any?
    remaining_templates.each do |template|
      expect(page).to have_content(template.name)
    end
  else
    # If no templates remain, verify empty state message
    expect(
      page.has_content?('No templates available') ||
      page.has_content?('Nenhum template disponível')
    ).to be true
  end
end

Then("I should not be able to be able to delete the Templates") do
  # Verify that deletion is not possible when there are no templates
  # No delete buttons should be present
  expect(page).not_to have_css('.btn-delete')
end
