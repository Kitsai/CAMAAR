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
end
