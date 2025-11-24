class QuestionSet < ApplicationRecord
  has_many :templates
  has_many :forms
end
