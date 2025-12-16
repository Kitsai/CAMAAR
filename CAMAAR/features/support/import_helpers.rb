# Cucumber helpers for import testing
# Similar to spec/support/import_request_helpers.rb but for Cucumber

# Include RSpec mocks for Cucumber
require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
end

After do
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end
end

module ImportHelpers
  # Mock a successful import with customizable statistics
  def mock_successful_import(stats = {})
    default_stats = {
      users_created: 2,
      users_skipped: 0,
      courses_created: 1,
      courses_skipped: 0,
      enrollments_created: 1,
      errors: []
    }

    allow_any_instance_of(JsonImportService).to receive(:call).and_return({
      success: true,
      data: default_stats.merge(stats)
    })
  end

  # Mock a failed import with an error message
  def mock_failed_import(error_message = "Classes file not found")
    allow_any_instance_of(JsonImportService).to receive(:call).and_return({
      success: false,
      error: error_message
    })
  end

  # Mock an import with partial success (some errors)
  def mock_partial_import(stats = {})
    default_stats = {
      users_created: 2,
      users_skipped: 0,
      courses_created: 1,
      courses_skipped: 0,
      enrollments_created: 2,
      errors: ["User validation failed for invalid@email"]
    }

    allow_any_instance_of(JsonImportService).to receive(:call).and_return({
      success: true,
      data: default_stats.merge(stats)
    })
  end

  # Mock an import with no data (empty files)
  def mock_empty_import
    mock_failed_import("Classes file not found")
  end

  # Mock an import with invalid JSON format
  def mock_invalid_format_import
    mock_failed_import("Invalid JSON format in classes.json")
  end

  # Reset import mocks (call in After hooks if needed)
  def reset_import_mocks
    allow_any_instance_of(JsonImportService).to receive(:call).and_call_original
  end
end

World(ImportHelpers)
