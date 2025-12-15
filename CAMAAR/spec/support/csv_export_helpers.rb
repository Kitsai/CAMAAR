module CsvExportHelpers
  # Validates CSV response headers
  def expect_csv_download_response(response)
    expect(response.content_type).to include("text/csv")
    expect(response.headers['Content-Disposition']).to include('attachment')
  end

  # Validates CSV contains question headers
  def expect_csv_headers(csv_string, questions)
    questions.each do |question|
      question_text = question["text"] || question["question"]
      expect(csv_string).to include(question_text)
    end
  end

  # Validates CSV contains answer data
  def expect_csv_contains_answers(csv_string, *answers)
    answers.flatten.each do |answer|
      expect(csv_string).to include(answer)
    end
  end

  # Validates service result success
  def expect_successful_csv_export(result)
    expect(result[:success]).to be true
    expect(result[:csv_data]).to be_present
  end

  # Calls the CSV exporter service
  def call_csv_exporter(admin, form_id)
    described_class.new(admin, form_id).call
  end

  # Validates service result failure
  def expect_csv_export_error(result, error_message)
    expect(result[:success]).to be false
    expect(result[:error]).to eq(error_message)
  end

  # Validates CSV contains special characters
  def expect_csv_escapes_special_chars(csv_data, *expected_strings)
    expected_strings.each do |string|
      expect(csv_data).to include(string)
    end
  end

  # Creates an admin record from user with :admin trait
  def create_admin_record_for_csv
    create(:user, :admin).admin
  end
end

RSpec.configure do |config|
  config.include CsvExportHelpers, type: :service
end
