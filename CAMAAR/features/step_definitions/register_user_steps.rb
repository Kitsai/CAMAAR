# Step definitions for user registration

Given('there is an importable user') do
  @importable_user = { email: 'newuser@example.com', name: 'New User' }
end

Given('there is an importable user with an invalid email address') do
  @importable_user = { email: 'invalid', name: 'Invalid User' }
end

Then('a registration email should be sent to the user\'s email') do
  # Check for email sent confirmation or similar message
  expect(page).to have_content('email sent')
end

Then('no registration email should be sent') do
  expect(page).not_to have_content('email sent')
end

Then('I should see an error message indicating the import failed') do
  expect(page).to have_content('Import failed')
end

Then('I should see an error message indicating the email is invalid') do
  expect(page).to have_content('invalid email')
end
