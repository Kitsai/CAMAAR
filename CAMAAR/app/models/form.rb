class Form < ApplicationRecord
  belongs_to :admin
  belongs_to :course
  belongs_to :question_set
end
