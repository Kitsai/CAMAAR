module CucumberCsvHelpers
  def verify_csv_download(page)
    expect(page.response_headers['Content-Type']).to include('text/csv')
    expect(page.response_headers['Content-Disposition']).to include('attachment')
  end

  def verify_csv_content(page, *content_items)
    content_items.each { |item| expect(page.body).to include(item) }
  end
end

World(CucumberCsvHelpers)
