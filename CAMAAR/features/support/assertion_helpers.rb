# frozen_string_literal: true

# Assertion helpers for Cucumber step definitions
# Provides reusable assertion methods to simplify complex conditional expectations
module AssertionHelpers
  # Checks for disabled button with multiple possible CSS selectors
  #
  # @param button_text [String] The text of the button to check
  # @example
  #   expect_button_disabled("Submit")
  def expect_button_disabled(button_text)
    expect(
      page.has_css?("a.disabled", text: button_text) ||
      page.has_css?("button[disabled]", text: button_text)
    ).to be true
  end

  # Checks for CSS element absence (e.g., no edit/delete buttons)
  #
  # @param button_class [String] The CSS class selector for the button
  # @example
  #   expect_no_action_buttons('.btn-edit')
  def expect_no_action_buttons(button_class)
    expect(page).not_to have_css(button_class)
  end

  # Checks for empty state message in multiple languages
  #
  # @param english_message [String] The English version of the empty state message
  # @param portuguese_message [String] The Portuguese version of the empty state message
  # @example
  #   expect_empty_state_message('No templates available', 'Nenhum template disponível')
  def expect_empty_state_message(english_message, portuguese_message)
    expect(
      page.has_content?(english_message) ||
      page.has_content?(portuguese_message)
    ).to be true
  end

  # Verifies list content or empty state
  #
  # @param items [ActiveRecord::Relation, Array] The collection of items to display
  # @param empty_en [String] English empty state message
  # @param empty_pt [String] Portuguese empty state message
  # @example
  #   expect_list_or_empty_state(Template.all, 'No templates available', 'Nenhum template disponível')
  def expect_list_or_empty_state(items, empty_en, empty_pt)
    if items.any?
      items.each { |item| expect(page).to have_content(item.name) }
    else
      expect_empty_state_message(empty_en, empty_pt)
    end
  end

  # Verifies success message appears
  #
  # @param message [String] The success message to verify
  # @example
  #   expect_success_message('Template updated successfully')
  def expect_success_message(message)
    expect(page).to have_content(message)
  end

  # Verifies content visibility after waiting
  #
  # @param content [String] The content to verify
  # @param timeout [Integer] Maximum wait time in seconds (default: 5)
  # @example
  #   expect_content_after_wait('Template deleted successfully', timeout: 3)
  def expect_content_after_wait(content, timeout: 5)
    using_wait_time(timeout) do
      expect(page).to have_content(content)
    end
  end
end

World(AssertionHelpers)
