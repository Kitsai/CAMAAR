class Form < ApplicationRecord
  belongs_to :admin
  belongs_to :course
  belongs_to :question_set

  has_many :form_requests
  has_many :users, through: :form_requests

  has_many :answers
end
