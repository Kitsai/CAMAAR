# frozen_string_literal: true

# Modal interaction helpers for Cucumber step definitions
# Provides reusable methods for standardizing modal opening, waiting, and interaction patterns
module ModalHelpers
  # Waits for modal to be visible with configurable timeout
  # Default timeout: 5 seconds (matches existing pattern)
  #
  # @param timeout [Integer] Maximum wait time in seconds (default: 5)
  # @example
  #   wait_for_modal
  #   wait_for_modal(timeout: 10)
  def wait_for_modal(timeout: 5)
    using_wait_time(timeout) do
      expect(page).to have_css('.modal.active', visible: true)
    end
  end

  # Opens a modal and waits for it to be visible
  #
  # @param selector [String] CSS selector for the element that opens the modal
  # @param timeout [Integer] Maximum wait time in seconds (default: 5)
  # @example
  #   open_modal_and_wait('.template-card')
  def open_modal_and_wait(selector, timeout: 5)
    find(selector, match: :first).click
    wait_for_modal(timeout: timeout)
  end

  # Checks if modal is currently visible
  #
  # @return [Boolean] True if modal is visible, false otherwise
  # @example
  #   if modal_visible?
  #     # perform modal actions
  #   end
  def modal_visible?
    page.has_css?('.modal.active', visible: true)
  end

  # Waits for modal to disappear (after submission)
  #
  # @param timeout [Integer] Maximum wait time in seconds (default: 5)
  # @example
  #   wait_for_modal_to_close
  def wait_for_modal_to_close(timeout: 5)
    using_wait_time(timeout) do
      expect(page).not_to have_css('.modal.active', visible: true)
    end
  end

  # Clicks element and waits for modal with title verification
  #
  # @param selector [String] CSS selector for the element that opens the modal
  # @param expected_title [String] The expected title text in the modal
  # @param timeout [Integer] Maximum wait time in seconds (default: 5)
  # @example
  #   open_modal_with_title('.btn-edit', 'Editar Template')
  def open_modal_with_title(selector, expected_title, timeout: 5)
    find(selector, match: :first).click
    using_wait_time(timeout) do
      expect(page).to have_css('.modal.active', visible: true)
      expect(page).to have_content(expected_title)
    end
  end
end

World(ModalHelpers)
