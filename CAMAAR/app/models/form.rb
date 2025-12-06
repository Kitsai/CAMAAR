class Form < ApplicationRecord
  belongs_to :admin
  belongs_to :course
  belongs_to :question_set

  has_many :form_requests, dependent: :destroy
  has_many :users, through: :form_requests

  has_many :answers, dependent: :destroy
end
