class QuestionSet < ApplicationRecord
  has_one :template
  has_many :forms

  validate :data_must_be_valid_json_array

  private

  def data_must_be_valid_json_array
    if data.nil?
      errors.add(:data, "can't be blank")
      return
    end

    unless data.is_a?(Array)
      errors.add(:data, "must be a non-empty array of questions")
      return
    end

    if data.empty?
      errors.add(:data, "must be a non-empty array of questions")
    end
  end
end
