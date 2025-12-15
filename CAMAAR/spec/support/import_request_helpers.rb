module ImportRequestHelpers
  def post_import
    post imports_path
  end

  def expect_import_statistics(users: nil, courses: nil, enrollments: nil, users_skipped: nil)
    follow_redirect! if response.status == 302
    expect(response.body).to include("#{users} users created") if users
    expect(response.body).to include("#{courses} courses created") if courses
    expect(response.body).to include("#{enrollments} enrollments created") if enrollments
    expect(response.body).to include("#{users_skipped} users skipped") if users_skipped
  end

  def expect_import_error(message)
    follow_redirect! if response.status == 302
    expect(response.body).to include("Import failed")
    expect(response.body).to include(message)
  end

  def expect_import_success
    follow_redirect! if response.status == 302
    expect(response.body).to include("Import completed successfully")
  end

  def mock_successful_import(stats = {})
    default_stats = {
      users_created: 5,
      users_skipped: 2,
      courses_created: 3,
      courses_skipped: 0,
      enrollments_created: 15,
      errors: []
    }
    allow_any_instance_of(JsonImportService).to receive(:call).and_return({
      success: true,
      data: default_stats.merge(stats)
    })
  end

  def mock_failed_import(error_message)
    allow_any_instance_of(JsonImportService).to receive(:call).and_return({
      success: false,
      error: error_message
    })
  end
end

RSpec.configure do |config|
  config.include ImportRequestHelpers, type: :request
end
