# frozen_string_literal: true

# Page interaction helpers for Cucumber step definitions
# Provides reusable page interaction methods for common patterns
module PageHelpers
  # Refreshes current page and waits for specific content/CSS
  #
  # @param css_selector [String, nil] CSS selector to wait for (optional)
  # @param content [String, nil] Content text to wait for (optional)
  # @param timeout [Integer] Maximum wait time in seconds (default: 5)
  # @example
  #   refresh_and_wait_for(css_selector: '.btn-delete')
  #   refresh_and_wait_for(content: 'Welcome')
  def refresh_and_wait_for(css_selector: nil, content: nil, timeout: 5)
    visit current_path
    # have_css and have_content already have built-in waiting, no need for using_wait_time
    expect(page).to have_css(css_selector, wait: timeout) if css_selector
    expect(page).to have_content(content, wait: timeout) if content
  end

  # Clicks first element matching selector if it exists, raises error if not
  #
  # @param selector [String] CSS selector for the element to click
  # @param error_message [String, nil] Custom error message (optional)
  # @raise [RuntimeError] If element is not found
  # @example
  #   click_first_if_exists('.btn-edit', error_message: "No edit button found")
  def click_first_if_exists(selector, error_message: nil)
    if page.has_css?(selector)
      first(selector).click
    else
      raise error_message || "No element found with selector: #{selector}"
    end
  end

  # Clicks first element with optional confirm dialog
  #
  # @param selector [String] CSS selector for the element to click
  # @param error_message [String, nil] Custom error message (optional)
  # @raise [RuntimeError] If element is not found
  # @example
  #   click_first_with_confirm('.btn-delete', error_message: "No delete button found")
  def click_first_with_confirm(selector, error_message: nil)
    if page.has_css?(selector)
      accept_confirm { first(selector).click }
    else
      raise error_message || "No element found with selector: #{selector}"
    end
  end

  # Waits for page to have specific cards loaded
  #
  # @param selector [String] CSS selector for the cards (default: '.template-card')
  # @param timeout [Integer] Maximum wait time in seconds (default: 5)
  # @example
  #   wait_for_cards('.form-card', timeout: 3)
  def wait_for_cards(selector = '.template-card', timeout: 5)
    expect(page).to have_css(selector, wait: timeout)
  end

  # Generic wait with custom expectation block
  #
  # @param timeout [Integer] Maximum wait time in seconds (default: 5)
  # @yield Block containing expectations to execute with timeout
  # @example
  #   wait_with_timeout(timeout: 3) do
  #     expect(page).to have_content('Loaded')
  #   end
  def wait_with_timeout(timeout: 5)
    using_wait_time(timeout) { yield }
  end
end

World(PageHelpers)
