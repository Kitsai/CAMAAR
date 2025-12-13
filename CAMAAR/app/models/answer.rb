class Answer < ApplicationRecord
  require 'csv'
  
  belongs_to :form

  validates :data, presence: true

  # Parse answer data from CSV format
  def parsed_data
    CSV.parse_line(data) || []
  rescue CSV::MalformedCSVError
    # Fallback for legacy data stored with simple comma separation
    data.split(',')
  end

  # Get a specific answer by index
  def answer_at(index)
    parsed_data[index]
  end

  # Get all answers as an array
  def answers
    parsed_data
  end
end
